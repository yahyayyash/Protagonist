//
//  BoardingOneController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 04/05/21.
//

import UIKit

class BoardingOneController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var yourName: UITextField!
    @IBOutlet weak var createButton: GenericButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createButton.layer.borderWidth = 2.0
        createButton.layer.cornerRadius = 20
        createButton.layer.masksToBounds = true
        createButton.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        createButton.isEnabled = false
        createButton.alpha = 0.25
        
        yourName.addBottomBorder(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        yourName.delegate = self
        yourName.addDoneButtonOnKeyboard()
    }
    
    @IBAction func continueBoard(_ sender: Any) {
        var username = yourName.text
        if username == nil || username == "" {
            username = "Guest"
        }
        UserDefaults.standard.setValue(username, forKey: "Username")
        performSegue(withIdentifier: "boardingOne", sender: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
        case yourName:
            let _ = (yourName.text! as NSString).replacingCharacters(in: range, with: string)
        default:
            break
        }
        
        if textField.text!.isEmpty || (textField.text!.count == 1 && string == "") {
            createButton.isEnabled = false
            createButton.alpha = 0.25
        } else {
            createButton.isEnabled = true
            createButton.alpha = 1.0
        }
        return true
    }
}

// MARK: - Extension UITextField

extension UITextField{
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}

