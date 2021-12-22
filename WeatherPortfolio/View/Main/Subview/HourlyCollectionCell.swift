//
//  HourlyCell.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/17/21.
//

import UIKit

class HourlyCollectionCell: UICollectionViewCell {
    
    private var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        stack.contentMode = .center
        stack.backgroundColor = .clear
        return stack
    }()
    
    private let topLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.font = UIFont.smallTitle
        return lbl
    }()
    
    private var iconIV: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private var bottomLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white.withAlphaComponent(0.6)
        lbl.textAlignment = .center
        lbl.font = UIFont.extraSmallTitle
        return lbl
    }()
    
    lazy var backImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "blueBack"))
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var isCurrent: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = 20
        clipsToBounds = true
        
        
        if isCurrent {
            contentView.addSubview(backImageView)
            NSLayoutConstraint.activate([
                backImageView.topAnchor.constraint(equalTo: topAnchor),
                backImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                backImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                backImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 0.5
        } else {
            layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
            layer.borderWidth = 0.5
        }
        
        containerStack.addArrangedSubview(topLbl)
        containerStack.addArrangedSubview(iconIV)
        containerStack.addArrangedSubview(bottomLbl)
        
        NSLayoutConstraint.activate([
            topLbl.heightAnchor.constraint(equalToConstant: 20),
            bottomLbl.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        contentView.addSubview(containerStack)
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        
        topLbl.text = "23"
        iconIV.image = UIImage(named: "test")
        bottomLbl.text = "11:00"
        
    }
    
}
