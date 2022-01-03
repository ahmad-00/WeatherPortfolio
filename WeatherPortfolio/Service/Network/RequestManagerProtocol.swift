//
//  RequestManagerProtocol.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 1/3/22.
//

import Foundation
import Combine

protocol RequestManagerProtocol {
    func getWeatherIcon(name: String) -> AnyPublisher<Data?, URLError>
    func getGeoData(searchTerm: String) -> AnyPublisher<[GeoData]?, RequestError>
    func getWeatherInfo(lat: Double, lng: Double) -> AnyPublisher<Weather, RequestError>
    func getLocationName(lat: Double, lng: Double) -> AnyPublisher<ReverseGeoData, RequestError>
}
