//
//  TodayView.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/19/21.
//

import UIKit
import Combine

class TodayView: UIView {
    
    private var cancelable = Set<AnyCancellable>()
    
    private var backIV: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "blueBack"))
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        stack.contentMode = .center
        stack.spacing = 6
        stack.backgroundColor = .clear
        return stack
    }()
    
    private var currentLocationLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.mediumSemiBoldTitle
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()
    
    private var mainIconIV: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private var currentTemp: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.font = UIFont.superLargeHeavyTitle
        return lbl
    }()
    
    private var currentWeatherStatusLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.font = UIFont.largeTitle
        lbl.textColor = .white
        return lbl
    }()
    
    private var separatorLineView: UIView = {
        let vi = UIView()
        vi.translatesAutoresizingMaskIntoConstraints = false
        vi.backgroundColor = UIColor(white: 1, alpha: 0.4)
        return vi
    }()
    
    private var detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalCentering
        stack.axis = .horizontal
        stack.contentMode = .center
        stack.backgroundColor = .clear
        return stack
    }()
    
    private var windView: WeatherItemView = {
        let vi = WeatherItemView()
        vi.translatesAutoresizingMaskIntoConstraints = false
        vi.title = "Wind"
        vi.icon = UIImage(named: "wind")
        vi.value = "13 km/h"
        return vi
    }()
    
    private var humidityView: WeatherItemView = {
        let vi = WeatherItemView()
        vi.translatesAutoresizingMaskIntoConstraints = false
        vi.title = "Humidity"
        vi.icon = UIImage(named: "humidity")
        vi.value = "24%"
        return vi
    }()
    
    private var rainChanceView: WeatherItemView = {
        let vi = WeatherItemView()
        vi.translatesAutoresizingMaskIntoConstraints = false
        vi.title = "Chance of rain"
        vi.icon = UIImage(named: "chance_of_rain")
        vi.value = "87%"
        return vi
    }()
    
    private var viewModel: MainVM
    
    init(viewModel: inout MainVM) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        initSubscribers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(backIV)
        NSLayoutConstraint.activate([
            backIV.leadingAnchor.constraint(equalTo: leadingAnchor),
            backIV.trailingAnchor.constraint(equalTo: trailingAnchor),
            backIV.topAnchor.constraint(equalTo: topAnchor),
            backIV.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        backIV.layer.shadowColor = UIColor(red: 94/255, green: 153/255, blue: 231/255, alpha: 1).cgColor
        backIV.layer.shadowOffset = CGSize(width: 0, height: 1)
        backIV.layer.shadowRadius = 5
        backIV.layer.shadowOpacity = 0.6
        
        
        detailsStack.addArrangedSubview(windView)
        detailsStack.addArrangedSubview(humidityView)
        detailsStack.addArrangedSubview(rainChanceView)
        
        
        containerStack.addArrangedSubview(currentLocationLbl)
        containerStack.addArrangedSubview(mainIconIV)
        containerStack.addArrangedSubview(currentTemp)
        containerStack.addArrangedSubview(currentWeatherStatusLbl)
        containerStack.addArrangedSubview(separatorLineView)
        containerStack.addArrangedSubview(detailsStack)
        
        NSLayoutConstraint.activate([
            currentLocationLbl.heightAnchor.constraint(equalToConstant: 26),
            currentWeatherStatusLbl.heightAnchor.constraint(equalToConstant: 30),
            currentTemp.heightAnchor.constraint(equalToConstant: 80),
            separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            detailsStack.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        backIV.addSubview(containerStack)
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: backIV.topAnchor, constant: 12),
            containerStack.bottomAnchor.constraint(equalTo: backIV.bottomAnchor, constant: -12),
            containerStack.leadingAnchor.constraint(equalTo: backIV.leadingAnchor, constant: 16),
            containerStack.trailingAnchor.constraint(equalTo: backIV.trailingAnchor, constant: -16)
        ])
        
    }
    
    private func initSubscribers() {
        viewModel
            .weatherInfoWitLocation
            .receive(on: RunLoop.main)
            .compactMap({$0})
            .sink {[weak self] weatherLocationInfo in
                logger.debug("=-=-=Did Received Weather Info=-=-=")
                guard let `self` = self else {return}
                
                let weatherInfo = weatherLocationInfo.0
                let locationInfo = weatherLocationInfo.1
                
                self.currentLocationLbl.text = locationInfo
                self.currentTemp.text = String(Int(weatherInfo.current?.temp ?? Double()))
                self.currentWeatherStatusLbl.text = weatherInfo.current?.weather?[0].weatherDescription ?? ""
                self.windView.value = "\(weatherInfo.current?.windSpeed ?? Double())km/h"
                self.humidityView.value = "\(weatherInfo.current?.humidity ?? 0)%"
                self.rainChanceView.value = "N/A"
            }
            .store(in: &cancelable)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backIV.layer.shadowPath = UIBezierPath(roundedRect: backIV.bounds, cornerRadius: 35).cgPath
        
    }
    
}


fileprivate class WeatherItemView: UIView {
    
    private var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        stack.axis = .vertical
        stack.contentMode = .bottom
        stack.spacing = 0
        stack.backgroundColor = .clear
        return stack
    }()
    
    private var iconIV: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .white
        return iv
    }()
    
    private let valueLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.font = UIFont.smallTitle
        return lbl
    }()
    
    private var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white.withAlphaComponent(0.6)
        lbl.textAlignment = .center
        lbl.font = UIFont.smallTitle
        return lbl
    }()
    
    var title: String? {
        didSet {
            titleLbl.text = self.title
        }
    }
    
    var value: String? {
        didSet {
            valueLbl.text = self.value
        }
    }
    
    var icon: UIImage? {
        didSet {
            iconIV.image = self.icon
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        
        containerStack.addArrangedSubview(iconIV)
        containerStack.addArrangedSubview(valueLbl)
        containerStack.addArrangedSubview(titleLbl)
        
        NSLayoutConstraint.activate([
            valueLbl.heightAnchor.constraint(equalToConstant: 20),
            titleLbl.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        addSubview(containerStack)
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
    }
    
    
}
