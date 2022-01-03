//
//  WeatherPortfolioTests.swift
//  WeatherPortfolioTests
//
//  Created by Ahmad Mohammadi on 12/17/21.
//

import XCTest
import Combine
@testable import WeatherPortfolio

class WeatherPortfolioTests: XCTestCase {

    private var requestManager = RequestManager()
    private var requestManagerMock = RequestManagerMock()
    private var cancelable = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGetWeatherInfo() {
        
        let expectation = self.expectation(description: "GetWeatherInfoExpectation")
        _ = requestManager
            .getWeatherInfo(lat: 40.730610, lng: -73.935242)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: RunLoop.main)
            .sink {_result in
                switch _result {
                case .failure(_):
                    XCTFail("Get Weather Info Failed")
                    expectation.fulfill()
                    break
                case .finished:
                    break
                }
                
            } receiveValue: {_ in
                expectation.fulfill()
            }

        self.waitForExpectations(timeout: 10)
    }
    
    func testGetLocationInfo() {
        
        let expectation = self.expectation(description: "GetLocationInfoExpectation")
        
        _ = requestManager
            .getLocationName(lat: 40.730610, lng: -73.935242)
            .subscribe(on: RunLoop.main)
            .sink {_result in
                switch _result {
                case .failure(_):
                    XCTFail("Get Weather Info Failed")
                    expectation.fulfill()
                    break
                case .finished:
                    break
                }
            } receiveValue: {reverseGeoData in
                XCTAssertEqual(reverseGeoData.name, "New York")
                XCTAssertEqual(reverseGeoData.country, "US")
                expectation.fulfill()
            }
        self.waitForExpectations(timeout: 10)
    }
    
    
    func testMainViewModel() {
        let expectation = self.expectation(description: "MainViewModelExpectation")
        let mainVM = MainVM(requestManager: requestManagerMock)
        mainVM
            .weatherInfoWitLocation
            .receive(on: RunLoop.main)
            .compactMap({$0})
            .sink { (_weather, _reverseGeoData) in
                XCTAssertEqual(_weather.current?.temp, 11.13)
                expectation.fulfill()
            }
            .store(in: &cancelable)
        
        LocationManager
            .shared
            .userLocation = Location(lat: 1.11, lng: 1.11)
        
        self.waitForExpectations(timeout: 8)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
