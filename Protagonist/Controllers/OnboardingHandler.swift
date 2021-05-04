//
//  OnboardingHandler.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 04/05/21.
//

import Foundation
import UIKit

class OnboardingHandler {
    static let shared = OnboardingHandler()
    
    var isFirstLaunch: Bool {
        get {
            !UserDefaults.standard.bool(forKey: #function)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: #function)
        }
    }
}
