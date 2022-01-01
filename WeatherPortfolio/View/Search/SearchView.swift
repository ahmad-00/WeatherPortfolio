//
//  SearchView.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/30/21.
//

import UIKit
import Combine

class SearchView: UIViewController {
    
    private var viewModel: SearchVM
    private var cancelable = Set<AnyCancellable>()
    
    private var blueEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    private let titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Search Location"
        lbl.font = UIFont.mediumSemiBoldTitle
        lbl.textColor = UIColor.white.withAlphaComponent(0.9)
        return lbl
    }()
    
    private var searchView: UISearchBar = {
        let sv = UISearchBar()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.backgroundImage = UIImage()
        sv.searchTextField.textColor = .white
        return sv
    }()
    
    private var resultTbl: UITableView = {
        let tbl = UITableView(frame: .zero, style: .plain)
        tbl.rowHeight = 60
        tbl.translatesAutoresizingMaskIntoConstraints = false
        tbl.backgroundColor = .clear
        tbl.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tbl.keyboardDismissMode = .interactive
        return tbl
    }()
    
    init(viewModel: SearchVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.clear
        
        blueEffectView.frame = view.bounds
        view.addSubview(blueEffectView)
        
        view.addSubview(titleLbl)
        NSLayoutConstraint.activate([
            titleLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            titleLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            titleLbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLbl.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
        
        view.addSubview(searchView)
        searchView.layer.cornerRadius = 12
        searchView.clipsToBounds = true
        searchView.delegate = viewModel
        NSLayoutConstraint.activate([
            searchView.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: titleLbl.trailingAnchor),
            searchView.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 12),
            searchView.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        view.addSubview(resultTbl)
        resultTbl.register(UITableViewCell.self, forCellReuseIdentifier: locationSearchTableCellIdentifier)
        resultTbl.delegate = viewModel
        resultTbl.dataSource = viewModel
        NSLayoutConstraint.activate([
            resultTbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultTbl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultTbl.topAnchor.constraint(equalTo: searchView.bottomAnchor),
            resultTbl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        
        viewModel
            .$searchResult
            .receive(on: RunLoop.main)
            .sink(receiveValue: {[weak self] _ in
                guard let `self` = self else {return}
                logger.debug("Did Received Table Data source update")
                self.resultTbl.reloadData()
            })
            .store(in: &cancelable)
        
        viewModel
            .$shouldDismissView
            .receive(on: RunLoop.main)
            .sink { [weak self] _value in
                guard let `self` = self else {return}
                if _value {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            .store(in: &cancelable)
            
        
    }
    
}
