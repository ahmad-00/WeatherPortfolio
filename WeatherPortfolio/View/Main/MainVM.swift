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
    let weatherInfoWitLocation = CurrentValueSubject<(Weather, ReverseGeoData)?, Never>(nil)
    private var hourlyWeatherData = [CurrentInfo]()
    
    private var requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol) {
        self.requestManager = requestManager
        super.init()
        
        LocationManager
            .shared
            .$userLocation
            .drop(while: { $0 == nil })
            .compactMap{ $0 }
            .first()
            .flatMap { _locationData in
                requestManager
                    .getWeatherInfo(lat: _locationData.lat, lng: _locationData.lng)
                    .zip(
                        requestManager
                            .getLocationName(lat: _locationData.lat, lng: _locationData.lng)
                    )
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _result in
                
                switch _result {
                case .failure(let error):
                    print("=-=-=-", error.localizedDescription)
                case .finished:
                    break
                }
                
            }, receiveValue: {[weak self] _value in
                guard let `self` = self else {return}
                logger.debug("Received weatherInfoWitLocation => \(_value.1.name)")
                self.weatherInfoWitLocation.send(_value)
                if let hourlyData = _value.0.hourly {
                    self.hourlyWeatherData = hourlyData
                }
            })
            .store(in: &cancelable)

        
        
    }

    private func fetchNewLocationWeatherData(locationData:Location) {
        Publishers.Zip (
            requestManager
                .getWeatherInfo(lat: locationData.lat, lng: locationData.lng),
            requestManager
                .getLocationName(lat: locationData.lat, lng: locationData.lng)
        )
            .map { _weatherInfo, _locationName in
                (_weatherInfo, _locationName)
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _result in
                
                switch _result {
                case .failure(let error):
                    print("=-=-=-", error.localizedDescription)
                case .finished:
                    break
                }
                
            }, receiveValue: {[weak self] _value in
                guard let `self` = self else {return}
                logger.debug("Received weatherInfoWitLocation => \(_value.1.name)")
                if let hourlyData = _value.0.hourly {
                    self.hourlyWeatherData = hourlyData
                }
                self.weatherInfoWitLocation.send(_value)
            })
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
        fetchNewLocationWeatherData(locationData: Location(lat: lat, lng: lng))
    }
}
