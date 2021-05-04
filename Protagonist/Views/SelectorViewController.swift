//
//  SelectorViewController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 04/05/21.
//

import UIKit

class SelectorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidAppear(_ animated: Bool) {
        if OnboardingHandler.shared.isFirstLaunch {
            performSegue(withIdentifier: "toOnboarding", sender: nil)
            OnboardingHandler.shared.isFirstLaunch = true
        } else {
            performSegue(withIdentifier: "toMain", sender: nil)
        }
    }

}
