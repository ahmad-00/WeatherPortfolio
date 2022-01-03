//
//  IconImageView.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/24/21.
//

import UIKit
import Combine

class IconImageView: UIImageView {
    
    private var cancelable = Set<AnyCancellable>()
    
    private var requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol = RequestManager()) {
        self.requestManager = requestManager
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var shouldUseLocalIcon = true // set this to false to download icons. This option is available because icons from provider don't have good quality and I had to use local icons
    
    var iconName: String? = nil {
        didSet {
            if let name = iconName {
                setImage(name: name)
            }
        }
    }
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    private func setImage(name: String) {
        if !shouldUseLocalIcon {
            if let cachedImage = imageCache.object(forKey: name as NSString) {
                image = cachedImage
            } else {
                fetchImage(name: name)
            }
        } else {
            image = UIImage(named: name)
        }
        
        
    }
    
    private func fetchImage(name: String) {
        requestManager
            .getWeatherIcon(name: name)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: {_ in}) {[weak self] _data in
                guard let `self` = self else {return}
                if let data = _data {
                    if let image = UIImage(data: data) {
                        self.image = image
                        self.imageCache.setObject(image, forKey: name as NSString)
                    }
                    
                }
            }
            .store(in: &cancelable)
    }
    
}
