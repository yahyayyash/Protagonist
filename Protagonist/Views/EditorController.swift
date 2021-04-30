//
//  EditorController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 29/04/21.
//

import UIKit

class EditorController: UIViewController, UITextViewDelegate {
    
    var selected: JournalEntry?
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: CustomLabel!
    @IBOutlet weak var journalText: UITextView!
    @IBOutlet weak var mediaPlaceholder: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    let journalPlaceholderText: String = "Write down your thought here ... \nTap pencil icon to enable editing."
    
    let editedJournalPlaceholderText: String = "Tap here to start writing ..."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        checkJournalEntry()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editJournal))
        
        journalText.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(EditorController.handleKeyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(EditorController.handleKeybolardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    @objc func handleKeyboardDidShow(notification: NSNotification) {
        guard let keyboardRect = (notification
                                    .userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                    as? NSValue)?.cgRectValue else { return }
        
        //        bottomConstraint.constant = keyboardRect.height - 10
        journalText.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardRect.height - (journalText.font!.lineHeight * 2),
            right: 0
        )
        view.layoutIfNeeded()
    }
    
    @objc func handleKeybolardWillHide() {
        //        bottomConstraint.constant = 20
        journalText.contentInset = .zero
        view.layoutIfNeeded()
    }
    
    @objc func editJournal(){
        if self.isEditing {
            DatabaseDummy.shared.editDescription(entry: selected!, text: journalText.text)
            journalText.isEditable = false
            journalText.layer.borderColor = UIColor(red: 34/255, green: 4/255, blue: 4/255, alpha: 0.05).cgColor
            if journalText.text == editedJournalPlaceholderText {
                journalText.text = journalPlaceholderText
            }
            self.isEditing = false
            navigationItem.rightBarButtonItem = nil
            navigationItem.hidesBackButton = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editJournal))
        } else {
            journalText.isEditable = true
            journalText.layer.borderColor = UIColor.systemYellow.cgColor
            if journalText.text == journalPlaceholderText {
                journalText.text = editedJournalPlaceholderText
            }
            self.isEditing = true
            navigationItem.rightBarButtonItem = nil
            navigationItem.hidesBackButton = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editJournal))
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if journalText.textColor == .lightGray {
            journalText.text = nil
            journalText.textColor = .black
        }
        self.updateViewConstraints()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkJournalEntry()
    }
    
    func checkJournalEntry(){
        if journalText.text.isEmpty {
            journalText.text = journalPlaceholderText
            journalText.textColor = .lightGray
        }
    }
    
    func updateUI(){
        journalText.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        mediaPlaceholder.layer.cornerRadius = 10
        mediaPlaceholder.clipsToBounds = true
        videoThumbnail.image = selected?.thumbnail
        self.title = selected?.journalGroup?.title
        journalText.text = selected?.textDescription
    }
}

