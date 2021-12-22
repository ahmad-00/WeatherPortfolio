//
//  FontExt.swift
//  WeatherPortfolio
//
//  Created by Ahmad Mohammadi on 12/17/21.
//

import UIKit

extension UIFont {
    static var smallSemiBoldTitle: UIFont {
        get {
            return UIFont(descriptor: UIFont.systemFont(ofSize: 18, weight: .semibold).fontDescriptor.withDesign(.rounded)!,
                          size: 18)
        }
    }
    
    static var mediumSemiBoldTitle: UIFont {
        get {
            return UIFont(descriptor: UIFont.systemFont(ofSize: 23, weight: .semibold).fontDescriptor.withDesign(.rounded)!,
                          size: 23)
        }
    }
    
    static var superLargeHeavyTitle: UIFont {
        get {
            return UIFont(descriptor: UIFont.systemFont(ofSize: 80, weight: .heavy).fontDescriptor.withDesign(.rounded)!,
                          size: 80)
        }
    }
    
    static var largeTitle: UIFont {
        get {
            return UIFont(descriptor: UIFont.systemFont(ofSize: 26, weight: .regular).fontDescriptor.withDesign(.rounded)!,
                          size: 26)
        }
    }
    
    static var smallTitle: UIFont {
        get {
            return UIFont(descriptor: UIFont.systemFont(ofSize: 15, weight: .regular).fontDescriptor.withDesign(.rounded)!,
                          size: 15)
        }
    }
    
    static var extraSmallTitle: UIFont {
        get {
            return UIFont(descriptor: UIFont.systemFont(ofSize: 13, weight: .regular).fontDescriptor.withDesign(.rounded)!,
                          size: 13)
        }
    }
    
}
