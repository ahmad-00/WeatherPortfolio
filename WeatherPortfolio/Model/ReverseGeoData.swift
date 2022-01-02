//
//  ReverseGeoData.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/23/21.
//

import Foundation

struct ReverseGeoData: Codable {
    var name: String
    var country: String
}

typealias ReverseGeoDataResponse = [ReverseGeoData]
