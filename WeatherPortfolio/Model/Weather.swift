//
//  Weather.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/18/21.
//

import Foundation

struct Weather: Codable {
    let current: CurrentInfo?
    let hourly: [CurrentInfo]?
    let daily: [Daily]?

    enum CodingKeys: String, CodingKey {
        case current, hourly, daily
    }
}

// MARK: - Current
struct CurrentInfo: Codable {
    let temp, feelsLike: Double?
    let pressure, humidity: Int?
    let uvi: Double?
    let visibility: Int?
    let windSpeed: Double?
    let windDeg: Float?
    let weather: [CurrentWeather]?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case pressure, humidity
        case uvi, visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather
    }
}

// MARK: - Weather
struct CurrentWeather: Codable {
    let id: Int?
    let weatherDescription: String?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case id
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Daily
struct Daily: Codable {
    let temp: Temp?
    let weather: [Weather]?
}

// MARK: - Temp
struct Temp: Codable {
    let min, max: Float?
}
