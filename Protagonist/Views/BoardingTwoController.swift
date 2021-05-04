//
//  BoardingTwoController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 04/05/21.
//

import UIKit

class BoardingTwoController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var femaleImage: UIImageView!
    @IBOutlet weak var maleImage: UIImageView!
    @IBOutlet weak var blobImage: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    
    var selectedGender = "female"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        femaleImage.layer.opacity = 0.25
        maleImage.layer.opacity = 1.0
        continueButton.layer.borderWidth = 2.0
        continueButton.layer.cornerRadius = 20
        continueButton.layer.masksToBounds = true
        continueButton.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        femaleImage.isUserInteractionEnabled = true
        maleImage.isUserInteractionEnabled = true
        
        bouncyPosition(blobImage)
    }
    
    @IBAction func didTapMale(_ sender: UITapGestureRecognizer) {
        selectedGender = "male"
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
            self.femaleImage.alpha = 0.25
            self.maleImage.alpha = 1
            self.blobImage.layer.position = CGPoint(x: self.blobImage.frame.width / 2, y: self.viewContainer.frame.height / 2)
        }, completion: nil)
    }
    
    @IBAction func didTapFemale(_ sender: UITapGestureRecognizer) {
        selectedGender = "female"
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
            self.femaleImage.alpha = 1
            self.maleImage.alpha = 0.25
            self.blobImage.layer.position = CGPoint(x: self.viewContainer.frame.width - self.blobImage.frame.width / 2, y: self.viewContainer.frame.height / 2)
        }, completion: nil)
    }
    
    @IBAction func continueBoard(_ sender: Any?) {
        performSegue(withIdentifier: "boardingTwo", sender: self)
        UserDefaults.standard.setValue(selectedGender, forKey: "Gender")
    }
    
    func bouncyPosition(_ input: UIView){
        let origin = input.layer.position.y
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
            input.layer.position = CGPoint(x: 0, y: origin + 50)
        }, completion: nil)
    }
}
