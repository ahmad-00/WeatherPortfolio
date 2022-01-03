//
//  SearchVM.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/30/21.
//

import UIKit
import Combine

protocol SearchViewModelDelegate {
    func didSelectLocation(lat: Double, lng: Double)
}

class SearchVM: NSObject, ObservableObject {
    
    var delegate: SearchViewModelDelegate?
    private var cancelable = Set<AnyCancellable>()
    
    @Published var searchResult = [GeoData]()
    @Published var shouldDismissView: Bool = false
    
    private var searchTerm = PassthroughSubject<String, Never>()
    
    private var requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol) {
        self.requestManager = requestManager
        super.init()
        
        searchTerm
            .map({ _value in
                _value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            })
            .filter { _searchTerm in
                _searchTerm.count > 2
            }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .flatMap({ _value in
                requestManager
                    .getGeoData(searchTerm: _value)
                    .catch { _error -> Just<[GeoData]?> in
                        print("=-=-=- Error =>", _error)
                        return Just([])
                    }
                    .compactMap{ $0 }
            })
            .receive(on: RunLoop.main)
            .sink {[weak self] _value in
                guard let `self` = self else {return}
                logger.debug("Did Received Geo Data")
                self.searchResult = _value
            }
            .store(in: &cancelable)
        
    }
    
}

extension SearchVM: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: locationSearchTableCellIdentifier, for: indexPath)
        let result = searchResult[indexPath.row]
        var content = cell.defaultContentConfiguration()
        
        content.attributedText = NSAttributedString(string: result.text ?? "",
                                                    attributes: [
                                                        NSAttributedString.Key.foregroundColor: UIColor.white
                                                    ])
        
        content.secondaryAttributedText = NSAttributedString(string: result.placeName ?? "",
                                                             attributes: [
                                                                NSAttributedString.Key.foregroundColor: UIColor(white: 0.7, alpha: 1)
                                                             ])
        
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.contentView.alpha = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let coordinateInfo = searchResult[indexPath.row].center {
            delegate?.didSelectLocation(lat: coordinateInfo[1], lng: coordinateInfo[0])
            shouldDismissView = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4) {
            cell.contentView.alpha = 1
        }
    }
    
}

extension SearchVM: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        logger.debug("Search Text: \(searchText)")
        searchTerm.send(searchText)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        logger.debug("Search Text: \(searchBar.text ?? "")")
        if let searchText = searchBar.text {
            searchTerm.send(searchText)
        }
    }
    
}
