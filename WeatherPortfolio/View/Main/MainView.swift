//
//  MainView.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/17/21.
//

import UIKit
import Combine

class MainView: UIViewController, TodayViewDelegate {
    
    private var cancelable = Set<AnyCancellable>()

    private var todayLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.smallSemiBoldTitle
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.text = "Today"
        return lbl
    }()
    
    private var hourlyCV: HourlyCV = {
        let cv = HourlyCV()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private var viewModel: MainVM
    
    init(viewModel: MainVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        view.backgroundColor = .backColor
        
        let todayView = TodayView(viewModel: &viewModel)
        todayView.delegate = self
        todayView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(todayView)
        NSLayoutConstraint.activate([
            todayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            todayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            todayView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            todayView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7)
        ])
        
        view.addSubview(todayLabel)
        NSLayoutConstraint.activate([
            todayLabel.topAnchor.constraint(equalTo: todayView.bottomAnchor, constant: 8),
            todayLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 28),
            todayLabel.leadingAnchor.constraint(equalTo: todayView.leadingAnchor),
            todayLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
        
        hourlyCV.register(HourlyCollectionCell.self, forCellWithReuseIdentifier: hourlyCollectionCellIdentifier)
        hourlyCV.delegate = viewModel
        hourlyCV.dataSource = viewModel
        view.addSubview(hourlyCV)
        NSLayoutConstraint.activate([
            hourlyCV.topAnchor.constraint(equalTo: todayLabel.bottomAnchor),
            hourlyCV.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            hourlyCV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hourlyCV.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        viewModel
            .weatherInfoWitLocation
            .receive(on: RunLoop.main)
            .sink(receiveValue: {[weak self] _ in
                logger.debug("Did Receive weather update on MainView")
                guard let `self` = self else {return}
                self.hourlyCV.reloadData()
            })
            .store(in: &cancelable)

        
    }
    
    func didTapCurrentLocation() {
        logger.debug("Did Received Delegate")
        let searchView = SearchView()
        searchView.modalPresentationStyle = .formSheet
        present(searchView, animated: true, completion: nil)
    }
}
