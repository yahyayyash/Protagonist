//
//  AddJournalViewController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 30/04/21.
//

import UIKit
import CoreData

class AddJournalViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var sourceView = ""
    var sourceJournal: JournalData?
    var journalEntriesController: JournalEntriesController?
    var selectedView: UIViewController?
    var popupOrigin:CGFloat = 0
    
    @IBOutlet weak var tapView: UIVisualEffectView!
    @IBOutlet weak var popupModal: UIView!
    @IBOutlet weak var journalName: UITextField!
    @IBOutlet weak var journalDescription: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupOrigin = popupModal.frame.origin.y
        
        journalName.delegate = self
        journalDescription.delegate = self
        
        if journalName.text!.isEmpty || journalDescription.text!.isEmpty {
            createButton.isEnabled = false
        }
        
        popupModal.layer.cornerRadius = 10
        createButton.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        
        journalName.addDoneButtonOnKeyboard()
        journalDescription.addDoneButtonOnKeyboard()
        journalName.addBottomBorder(UIColor.ColorLibrary.blackDynamic.withAlphaComponent(0.25).cgColor)
        journalDescription.addBottomBorder(UIColor.ColorLibrary.blackDynamic.withAlphaComponent(0.25).cgColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch sourceView {
        case "editEntry":
            journalName.text = sourceJournal?.title
            journalDescription.text = sourceJournal?.subtitle
            createButton.setTitle("Save", for: .normal)
            break
        default:
            break
        }
    }
    
    @IBAction func dismissPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createJournal(_ sender: UIButton) {
        switch sourceView {
        case "createEntry":
            let newJournal = JournalData(context: self.context)
            newJournal.title = journalName.text ?? "Untitled"
            newJournal.subtitle = journalDescription.text ?? "Your description here"
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            let view = selectedView as? ViewController
            view?.backgroundImage.isHidden = true
            view?.avatarImage.isHidden = false
            view?.fetchJournal()
            view?.journalCollection.reloadData()
            
            self.dismiss(animated: true, completion: {
                view?.cellLayoutRefresh()
                view?.performSegue(withIdentifier: "latestSegue", sender: nil)
            })
            break
        case "editEntry":
            sourceJournal?.title = journalName.text ?? "Untitled"
            sourceJournal?.subtitle = journalDescription.text ?? "Your description here"
            do {
                try self.context.save()
            }
            catch {
                
            }
            journalEntriesController?.interfaceUpdate()
            self.dismiss(animated: true, completion: nil)
            break
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension UITextField {
    func addBottomBorder(_ color: CGColor){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 0.5)
        bottomLine.backgroundColor = color
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}

extension AddJournalViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
        case journalName:
            let _ = (journalName.text! as NSString).replacingCharacters(in: range, with: string)
        case journalDescription:
            let _ = (journalDescription.text! as NSString).replacingCharacters(in: range, with: string)
        default:
            break
        }
        
        (!journalName.text!.isEmpty && !journalDescription.text!.isEmpty) ? (createButton.isEnabled = true) : (createButton.isEnabled = false)
        
        return true
    }
}
