//
//  RequestManager.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/18/21.
//

import Foundation
import Combine

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



class RequestManager: RequestManagerProtocol {
    
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
    
    
    func getWeatherInfo(lat: Double, lng: Double) -> AnyPublisher<Weather, RequestError> {
        
        URLSession
            .shared
            .dataTaskPublisher(for: Endpoint.weatherInfo(lat: lat, lng: lng).url)
            .tryMap { (_data, _response) in
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
            }
            .decode(type: Weather.self, decoder: JSONDecoder())
            .mapError { _urlError -> RequestError in
                if let error = _urlError as? RequestError {
                    return error
                }
                return RequestError.ConnectionFailed
            }
            .eraseToAnyPublisher()
        
    }
    
    func getLocationName(lat: Double, lng: Double) -> AnyPublisher<ReverseGeoData, RequestError> {
        
        URLSession
            .shared
            .dataTaskPublisher(for: Endpoint.reverseGeoData(lat: lat, lng: lng).url)
            .tryMap { (_data, _response) in
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
            }
            .decode(type: ReverseGeoDataResponse.self, decoder: JSONDecoder())
            .map({$0[0]})
            .mapError { _urlError -> RequestError in
                if let error = _urlError as? RequestError {
                    return error
                }
                return RequestError.ConnectionFailed
            }
            .eraseToAnyPublisher()
        
    }
    
    
}
