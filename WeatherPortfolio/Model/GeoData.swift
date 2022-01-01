//
//  GeoLocationInfo.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/31/21.
//

import Foundation

struct GeoDataResponse: Codable {
    let features: [GeoData]?
}

struct GeoData: Codable {
    let text: String?
    let placeName: String?
    let center: [Double]?

    enum CodingKeys: String, CodingKey {
        case text = "text_en"
        case placeName = "place_name_en"
        case center
    }
}
