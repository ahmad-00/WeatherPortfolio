//
//  IntExt.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/23/21.
//

import Foundation

extension Int {
    func timestampToHour() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateStr = dateFormatter.string(from: date)
            
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }
        return ""
    }
}
