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
    
    var url: URL {
        switch self {
        case .weatherInfo(let lat, let lng):
            return URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lng)&exclude=minutely&appid=\(API_KEY)&units=metric")!
        case .image(let name):
            return URL(string: "http://openweathermap.org/img/wn/\(name)@2x.png")!
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
    
}
