//
//  RequestManagerMock.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 1/3/22.
//

import Foundation
import Combine
import UIKit


// MARK: URLS
fileprivate enum Endpoint {

    case weatherInfo(lat: Double, lng: Double)
    case image(name: String)
    case reverseGeoData(lat: Double, lng: Double)
    case geoData(searchTerm: String)
    
    var url: URL {
        switch self {
        case .weatherInfo(_, _):
            return Bundle.main.url(forResource: "weatherInfo", withExtension: "json")!
        case .reverseGeoData(_, _):
            return Bundle.main.url(forResource: "reverseGeoData", withExtension: "json")!
        case .image(let name):
            return URL(string: "https://openweathermap.org/img/wn/\(name)@4x.png")!
        case .geoData(let searchTerm):
            return URL(string: "https://api.mapbox.com/geocoding/v5/mapbox.places/\(searchTerm).json?limit=10&language=en&fuzzyMatch=true&access_token=\(MAP_BOX_API_KEY)")!
        }
    }
}


class RequestManagerMock: RequestManagerProtocol {
    
    func getWeatherIcon(name: String) -> AnyPublisher<Data?, URLError> {
        let imgData = UIImage(named: "test")!.pngData()!
        return Just(imgData)
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
    }
    
    func getGeoData(searchTerm: String) -> AnyPublisher<[GeoData]?, RequestError> {
        URLSession
            .shared
            .dataTaskPublisher(for: Endpoint.geoData(searchTerm: searchTerm).url)
            .tryMap({ (_data, _response) in
//                guard let statusCode = (_response as? HTTPURLResponse)?.statusCode else {
//                    throw RequestError.ConnectionFailed
//                }
//                
//                if statusCode == 429 {
//                    throw RequestError.RateLimitExceeded
//                } else if statusCode == 401 || statusCode == 403 {
//                    throw RequestError.AuthenticationFailed
//                } else if statusCode < 200 || statusCode > 299 {
//                    throw RequestError.ConnectionFailed
//                }
                
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
        print("=-=-=-=- Getting Weather Info")
        return URLSession
            .shared
            .dataTaskPublisher(for: Endpoint.weatherInfo(lat: lat, lng: lng).url)
            .handleEvents(receiveSubscription: nil, receiveOutput: {_ in print("Did Received Output")}, receiveCompletion: nil, receiveCancel: nil, receiveRequest: nil)
            .tryMap { (_data, _response) in
//                guard let statusCode = (_response as? HTTPURLResponse)?.statusCode else {
//                    throw RequestError.ConnectionFailed
//                }
//
//                if statusCode == 429 {
//                    throw RequestError.RateLimitExceeded
//                } else if statusCode == 401 || statusCode == 403 {
//                    throw RequestError.AuthenticationFailed
//                } else if statusCode < 200 || statusCode > 299 {
//                    throw RequestError.ConnectionFailed
//                }
                
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
        print("=-=-=-=- Getting Location Name")
        return URLSession
            .shared
            .dataTaskPublisher(for: Endpoint.reverseGeoData(lat: lat, lng: lng).url)
            .tryMap { (_data, _response) in
//                guard let statusCode = (_response as? HTTPURLResponse)?.statusCode else {
//                    throw RequestError.ConnectionFailed
//                }
//
//                if statusCode == 429 {
//                    throw RequestError.RateLimitExceeded
//                } else if statusCode == 401 || statusCode == 403 {
//                    throw RequestError.AuthenticationFailed
//                } else if statusCode < 200 || statusCode > 299 {
//                    throw RequestError.ConnectionFailed
//                }
                
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

