//
//  RequestError.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 1/3/22.
//

import Foundation

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
