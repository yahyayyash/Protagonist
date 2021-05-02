//
//  EditorController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 29/04/21.
//

import UIKit
import AVKit
import MobileCoreServices

class EditorController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selected: JournalEntry?
    var selectedGroup: JournalData?
    var videoUrlHandler: URL?
    var videoThumbnailHandler: UIImage?
    var editEntryHandler: String?
    var sourceHandler: String?
    var isEditRightAway: Bool?
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: CustomLabel!
    @IBOutlet weak var journalText: UITextView!
    @IBOutlet weak var mediaPlaceholder: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var textPlaceholder: RoundedCard!
    
    let journalPlaceholderText: String = "Write down your thought here ... \nTap pencil icon to enable editing."
    
    let editedJournalPlaceholderText: String = "Tap here to start writing ..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoUrlHandler = selected?.video
        updateUI()
        if (isEditRightAway ?? false) {
            editJournal()
        }
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
    
    @IBAction func selectSource(_ sender: Any) {
        
        if videoUrlHandler != nil {
            let player = AVPlayer(url: videoUrlHandler!)
            let vcPlayer = AVPlayerViewController()
            vcPlayer.player = player
            self.present(vcPlayer, animated: true, completion: nil)
        }
        if selected?.video == nil {
            let alert = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(
                                title: "Camera",
                                style: UIAlertAction.Style.default,
                                handler: { action in
                                    self.sourceHandler = "Camera"
                                    VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
                                }))
            alert.addAction(UIAlertAction(
                                title:"Album",
                                style: UIAlertAction.Style.default,
                                handler: { action in
                                    self.sourceHandler = "Album"
                                    VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
                                }))
            alert.addAction(UIAlertAction(
                                title:"Cancel",
                                style: UIAlertAction.Style.cancel,
                                handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            
        }
    }
    
    func updateUI(){
        
        selected == nil ? selectedIsNil() : selectedIsExist()
        
        if journalText.text.isEmpty {
            journalText.text = journalPlaceholderText
            journalText.textColor = .lightGray
        }
        
        if !journalText.isEditable {
            navigationItem.rightBarButtonItem = nil
            navigationItem.hidesBackButton = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editJournal))
        }
        
        dateLabel.text = customDateFormatter(dateInput: selected?.date ?? Date())[0]
        monthLabel.text = customDateFormatter(dateInput: selected?.date ?? Date())[1]
        
        mediaPlaceholder.clipsToBounds = true
        mediaPlaceholder.layer.cornerRadius = 10
        mediaPlaceholder.layer.borderWidth = 0.0
        journalText.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
    }
    
    func selectedIsNil(){
        self.title = "New Entry"
        playButton.isUserInteractionEnabled = false
        playButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
    }
    
    func selectedIsExist(){
        self.title = selected?.journals?.title
        if selected?.video != nil {
            self.playButton.isUserInteractionEnabled = true
            self.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        } else {
            self.playButton.isUserInteractionEnabled = false
            self.playButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        }
        
        if (selected?.thumbnail) != nil {
            videoThumbnail.image = UIImage(data: (selected?.thumbnail)!)
        }
        journalText.text = selected?.textDescription
    }
    
    func saveEntryAlert(){
        let alert = UIAlertController(
            title: "Content Changed",
            message: "Do you want to save your edits?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
                            title:"Discard",
                            style: UIAlertAction.Style.destructive,
                            handler: { action in
                                self.editEntryHandler = "Discard"
                                self.checkAlertHandler()
                                self.performSegue(withIdentifier: "unwindToB", sender: self)
                            }))
        alert.addAction(UIAlertAction(
                            title: "Save",
                            style: UIAlertAction.Style.default,
                            handler: { action in
                                self.editEntryHandler = "Save"
                                self.checkAlertHandler()
                                self.performSegue(withIdentifier: "unwindToB", sender: self)
                            }))
        present(alert, animated: true, completion: nil)
    }
    
    func checkAlertHandler(){
        switch editEntryHandler {
        case "Save":
            
            // Create new entry
            if selected == nil {
                let newEntry = JournalEntry(context: self.context)
                newEntry.date = Date()
                newEntry.journals = selectedGroup
                newEntry.textDescription = journalText.text
                newEntry.thumbnail = videoThumbnailHandler?.pngData()
                newEntry.video = videoUrlHandler
                
                do {
                    try self.context.save()
                    selected = newEntry
                }
                catch {
                    
                }
            
            // Update current entry
            } else {
                selected?.textDescription = journalText.text
                if selected?.video == nil {
                    selected?.video = videoUrlHandler
                    selected?.thumbnail = videoThumbnailHandler?.pngData()
                }
                do {
                    try self.context.save()
                }
                catch{
                    
                }
            }
            dissmissEntryAlert()
            
        case "Discard":
            dissmissEntryAlert()
            
        default:
            break
        }
    }
    
    func dissmissEntryAlert(){
        if selected?.textDescription != nil {
            journalText.text = selected?.textDescription
        } else {
            journalText.text = ""
        }
        if selected?.thumbnail != nil {
            videoThumbnail.image = UIImage(data: (selected?.thumbnail)!)
        } else {
            videoThumbnail.image = UIImage(named: "")
        }
        journalText.isEditable = false
        textPlaceholder.layer.borderColor = UIColor(red: 34/255, green: 4/255, blue: 4/255, alpha: 0.05).cgColor
        self.isEditing = false
        updateUI()
    }
}

// MARK: - UIITextViewDelegate
extension EditorController: UITextViewDelegate {
    @objc func editJournal(){
        if self.isEditing {
            saveEntryAlert()
        } else {
            journalText.isEditable = true
            self.isEditing = true
            playButton.isUserInteractionEnabled = true
            textPlaceholder.layer.borderColor = UIColor.systemYellow.cgColor
            mediaPlaceholder.layer.borderWidth = 1.0
            mediaPlaceholder.layer.borderColor = UIColor.systemYellow.cgColor
            print("Edit video")
            
            if journalText.text == journalPlaceholderText {
                journalText.text = editedJournalPlaceholderText
            }
            
            navigationItem.rightBarButtonItem = nil
            navigationItem.hidesBackButton = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editJournal))
        }
    }
    
    @objc func handleKeyboardDidShow(notification: NSNotification) {
        guard let keyboardRect = (notification
                                    .userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                    as? NSValue)?.cgRectValue else { return }
        
        journalText.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardRect.height - (journalText.font!.lineHeight * 2),
            right: 0
        )
        view.layoutIfNeeded()
    }
    
    @objc func handleKeybolardWillHide() {
        journalText.contentInset = .zero
        view.layoutIfNeeded()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if journalText.textColor == .lightGray {
            journalText.text = nil
            journalText.textColor = .black
        }
        self.updateViewConstraints()
    }
}
