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
        logger.debug("Did Init Location Manager")
        super.init()
        locationManager.delegate = self
        checkLocationAuthorizationStatus()
    }
    
    func checkLocationAuthorizationStatus() {
        if locationManager.authorizationStatus != .authorizedWhenInUse || locationManager.authorizationStatus != .authorizedAlways {
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
        logger.debug("Did Received location")
        let location: Location = Location(
            lat: locations[0].coordinate.latitude,
            lng: locations[0].coordinate.longitude
        )
        userLocation = location
        locationManager.stopUpdatingLocation()
    }
    
    
    
}
