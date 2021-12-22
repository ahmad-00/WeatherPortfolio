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
    
     var weatherInfo = CurrentValueSubject<Weather?, Never>(nil)
    
    override init() {
        super.init()
        
        locationCancelable = LocationManager
            .shared
            .$userLocation
            .sink {[weak self] _location in
                guard let `self` = self else {return}
                if let location = _location {
                    self.getWeatherInfo(lat: location.lat, lng: location.lng)
                    self.locationCancelable?.cancel()
                }
            }
        
    }
    
    func getWeatherInfo(lat: Double, lng: Double) {
        RequestManager.shared.getWeatherInfo(lat: lat, lng: lng)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: RunLoop.main)
            .sink { _result in
                
                switch _result {
                case .failure(let error):
                    print(error)
                    break
                case .finished:
                    break
                }
                
            } receiveValue: { _weather in
                print(_weather)
            }
            .store(in: &cancelable)
    }
    
}


extension MainVM: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: hourlyCollectionCellIdentifier, for: indexPath) as? HourlyCollectionCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height * 0.7,
                      height: collectionView.frame.height)
    }
    
}
