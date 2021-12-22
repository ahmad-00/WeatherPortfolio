//
//  HourlyCV.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/17/21.
//

import UIKit

class HourlyCV: UICollectionView {
    
    init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
//        register(HourlyCollectionCell.self, forCellWithReuseIdentifier: hourlyCollectionCellIdentifier)

    }
    
}
