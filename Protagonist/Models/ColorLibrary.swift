//
//  ColorLibrary.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 05/05/21.
//

import Foundation
import UIKit

extension UIColor {
    struct ColorLibrary {
        static var accentColor: UIColor { return UIColor(named: "AccentColor") ?? UIColor.clear }
        static var blackStatic: UIColor { return UIColor(named: "blackStatic") ?? UIColor.clear }
        static var blackDynamic: UIColor { return UIColor(named: "blackDynamic") ?? UIColor.clear }
        static var whiteStatic: UIColor { return UIColor(named: "whiteStatic") ?? UIColor.clear }
        static var whiteDynamic: UIColor { return UIColor(named: "whiteDynamic") ?? UIColor.clear }
    }
}
