//
//  RequestManager.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/18/21.
//

import Combine
import Foundation

// MARK: Errors
enum RequestError: Error {
    case ConnectionFailed
    case RateLimitExceeded
    case AuthenticationFailed
    
    var localizedDescription: String {
        switch self {
        case .ConnectionFailed:
            return NSLocalizedString("Connection failed. please try again", comment: "")
        case .RateLimitExceeded:
            return NSLocalizedString("Api key rate limit exceeded", comment: "")
        case .AuthenticationFailed:
            return NSLocalizedString("Invalid key provided", comment: "")
        }
    }
    
}

// MARK: URLS
fileprivate enum Endpoint {

    case weatherInfo(lat: Double, lng: Double)
    case image(name: String)
    case reverseGeoData(lat: Double, lng: Double)
    case geoData(searchTerm: String)
    
    var url: URL {
        switch self {
        case .weatherInfo(let lat, let lng):
            return URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lng)&exclude=minutely&appid=\(OPEN_WEATHER_API_KEY)&units=metric")!
        case .reverseGeoData(let lat, let lng):
            return URL(string: "https://api.openweathermap.org/geo/1.0/reverse?lat=\(lat)&lon=\(lng)&appid=\(OPEN_WEATHER_API_KEY)")!
        case .image(let name):
            return URL(string: "https://openweathermap.org/img/wn/\(name)@4x.png")!
        case .geoData(let searchTerm):
            return URL(string: "https://api.mapbox.com/geocoding/v5/mapbox.places/\(searchTerm).json?limit=10&language=en&fuzzyMatch=true&access_token=\(MAP_BOX_API_KEY)")!
        }
    }
}



class RequestManager {
    
    private init() {}
    
    public static let shared = RequestManager()
    
    func getWeatherInfo(lat: Double, lng: Double) -> Future<Weather, RequestError> {
        return Future {promise in
            URLSession
                .shared
                .dataTask(
                    with: Endpoint.weatherInfo(lat: lat, lng: lng).url) { _data, _response, _error in
                        
                        guard let statusCode = (_response as? HTTPURLResponse)?.statusCode else {
                            promise(.failure(.ConnectionFailed))
                            return
                        }
                        
                        if statusCode == 429 {
                            promise(.failure(.RateLimitExceeded))
                        } else if statusCode == 401 || statusCode == 403 {
                            promise(.failure(.AuthenticationFailed))
                        } else if statusCode < 200 || statusCode > 299 {
                            promise(.failure(.ConnectionFailed))
                        }
                        
                        guard let data = _data else {
                            promise(.failure(.ConnectionFailed))
                            return
                        }
                        
                        do {
                            let jsonDecoder = JSONDecoder()
                            let weather = try jsonDecoder.decode(Weather.self,from: data)
                            promise(.success(weather))
                        } catch {
                            promise(.failure(.ConnectionFailed))
                        }
                    }
                    .resume()
        }
    }
    
    func getLocationName(lat: Double, lng: Double) -> Future<ReverseGeoData, RequestError> {
        
        return Future {promise in
            URLSession
                .shared
                .dataTask(
                    with: Endpoint.reverseGeoData(lat: lat, lng: lng).url) { _data, _response, _error in
                        
                        guard let statusCode = (_response as? HTTPURLResponse)?.statusCode else {
                            promise(.failure(.ConnectionFailed))
                            return
                        }
                        
                        if statusCode == 429 {
                            promise(.failure(.RateLimitExceeded))
                        } else if statusCode == 401 || statusCode == 403 {
                            promise(.failure(.AuthenticationFailed))
                        } else if statusCode < 200 || statusCode > 299 {
                            promise(.failure(.ConnectionFailed))
                        }
                        
                        guard let data = _data else {
                            promise(.failure(.ConnectionFailed))
                            return
                        }
                        
                        do {
                            let jsonDecoder = JSONDecoder()
                            let reverseGeoData = try jsonDecoder.decode([ReverseGeoData].self,from: data)
                            
                            if reverseGeoData.isEmpty {
                                promise(.failure(.ConnectionFailed))
                                return
                            }
                            
                            promise(.success(reverseGeoData[0]))
                        } catch {
                            promise(.failure(.ConnectionFailed))
                        }
                    }
                    .resume()
        }
        
    }
    
    func getWeatherIcon(name: String) -> AnyPublisher<Data?, URLError> {
        return URLSession
            .shared
            .dataTaskPublisher(for: Endpoint.image(name: name).url)
            .map{$0.data}
            .eraseToAnyPublisher()
    }
    
    func getGeoData(searchTerm: String) -> AnyPublisher<[GeoData]?, RequestError> {
        
        URLSession
            .shared
            .dataTaskPublisher(for: Endpoint.geoData(searchTerm: searchTerm).url)
            .tryMap({ (_data, _response) in
                guard let statusCode = (_response as? HTTPURLResponse)?.statusCode else {
                    throw RequestError.ConnectionFailed
                }
                
                if statusCode == 429 {
                    throw RequestError.RateLimitExceeded
                } else if statusCode == 401 || statusCode == 403 {
                    throw RequestError.AuthenticationFailed
                } else if statusCode < 200 || statusCode > 299 {
                    throw RequestError.ConnectionFailed
                }
                
                return _data
                
            })
            .decode(type: GeoDataResponse.self, decoder: JSONDecoder())
            .map { $0.features }
            .mapError({ _urlError -> RequestError in
                if let error = _urlError as? RequestError {
                    return error
                }
                return RequestError.ConnectionFailed
            })
            .eraseToAnyPublisher()
        
    }
    
}
