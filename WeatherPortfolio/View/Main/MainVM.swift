//
//  MainVM.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/17/21.
//

import UIKit
import Combine

class MainVM: NSObject {
    
    private var cancelable = Set<AnyCancellable>()
    private var locationCancelable: AnyCancellable?
    
    private var weatherInfo = CurrentValueSubject<Weather?, Never>(nil)
    private var currentLocation = CurrentValueSubject<String?, Never>(nil)
    
    var weatherInfoWitLocation = CurrentValueSubject<(Weather, String)?, Never>(nil)
    
    private var hourlyWeatherData = [CurrentInfo]()
    
    override init() {
        super.init()
        
        weatherInfo
            .zip(currentLocation)
            .receive(on: RunLoop.main)
            .filter({$0.0 != nil && $0.1 != nil})
            .sink {[weak self] (_weatherInfo,_currentLocation) in
                guard let `self` = self else {return}
                if let hourlyData = self.weatherInfo.value?.hourly {
                    self.hourlyWeatherData = hourlyData
                    
                }
                self.weatherInfoWitLocation.send((_weatherInfo!, _currentLocation!))
            }
            .store(in: &cancelable)
        
        locationCancelable = LocationManager
            .shared
            .$userLocation
            .sink {[weak self] _location in
                guard let `self` = self else {return}
                if let location = _location {
                    logger.debug("Will Call for Weather Info")
                    self.getWeatherInfo(lat: location.lat, lng: location.lng)
                    self.getLocationInfo(lat: location.lat, lng: location.lng)
                    self.locationCancelable?.cancel()
                }
            }
    }
    
    func getWeatherInfo(lat: Double, lng: Double) {
        logger.debug("Did call get weather Info")
        RequestManager.shared.getWeatherInfo(lat: lat, lng: lng)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: RunLoop.main)
            .sink {_result in
                switch _result {
                case .failure(let error):
                    print(error)
                    break
                case .finished:
                    break
                }
                
            } receiveValue: {[weak self] _weather in
                guard let `self` = self else {return}
                self.weatherInfo.send(_weather)
            }
            .store(in: &cancelable)
    }
    
    func getLocationInfo(lat: Double, lng: Double) {
        logger.debug("Did call get Location Info")
        RequestManager.shared.getLocationName(lat: lat, lng: lng)
            .subscribe(on: RunLoop.main)
            .sink {[weak self] _result in
                guard let `self` = self else {return}
                switch _result {
                case .failure(let error):
                    print(error)
                    self.currentLocation.send(nil) // send nil data to make drop until consistant. Without this in case of error Weather info and Location name may not be for the same coordinate
                    break
                case .finished:
                    break
                }
            } receiveValue: {[weak self] _reverseGeoData in
                guard let `self` = self else {return}
                self.currentLocation.send(_reverseGeoData.name)
            }
            .store(in: &cancelable)
    }
    
}


extension MainVM: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyWeatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: hourlyCollectionCellIdentifier, for: indexPath) as? HourlyCollectionCell else {
            return UICollectionViewCell()
        }
        
        cell.weatherInfo = hourlyWeatherData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height * 0.65,
                      height: collectionView.frame.height * 0.9)
    }
    
}

extension MainVM: SearchViewModelDelegate {
    func didSelectLocation(lat: Double, lng: Double) {
        getLocationInfo(lat: lat, lng: lng)
        getWeatherInfo(lat: lng, lng: lng)
    }
}
