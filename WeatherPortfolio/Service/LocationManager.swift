//
//  LocationManager.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/19/21.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: Location? = nil
    
    static var shared = LocationManager()
    
    override init() {
        super.init()
    }
    
    func checkLocationAuthorizationStatus() {
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus == .denied {
            print("Location access denied")
            return
        } else if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: Location = Location(
            lat: locations[0].coordinate.latitude,
            lng: locations[0].coordinate.longitude
        )
        userLocation = location
        locationManager.stopUpdatingLocation()
    }
    
    
    
}
