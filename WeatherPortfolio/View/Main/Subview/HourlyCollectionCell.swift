//
//  HourlyCell.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/17/21.
//

import UIKit

class HourlyCollectionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .green
        layer.cornerRadius = 8
        clipsToBounds = true
        layer.borderColor = UIColor.brown.cgColor
        layer.borderWidth = 0.5
        
    }
    
}
