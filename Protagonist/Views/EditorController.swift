//
//  EditorController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 29/04/21.
//

import UIKit
import AVKit
import MobileCoreServices

class EditorController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    var journalEntriesController: JournalEntriesController?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selected: JournalEntry?
    var selectedGroup: JournalData?
    var videoUrlHandler: URL?
    var videoThumbnailHandler: UIImage?
    var editEntryHandler: String?
    var sourceHandler: String?
    var isEditRightAway: Bool?
    var alertMenu: UIAlertController?
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: CustomLabel!
    @IBOutlet weak var journalText: UITextView!
    @IBOutlet weak var mediaPlaceholder: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var textPlaceholder: RoundedCard!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageSubtitle: CustomLabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var topNavView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.adjustsImageWhenHighlighted = false
        menuButton.menu = menuItems()
        
        videoUrlHandler = selected?.video
        
        if (isEditRightAway ?? false) {
            editJournal()
        }
        
        journalText.delegate = self
        presentationController?.delegate = self
        
        journalText.addDoneButtonOnKeyboard()
        updateUI()
    }
    
    func menuItems() -> UIMenu {
        
        let saveAction = UIAction(title: "Save", image: UIImage(systemName: "square.and.arrow.down")) { _ in
            self.editEntryHandler = "Save"
            self.checkAlertHandler()
        }
        
        let discardAction = UIAction(title: "Discard", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        let changeAction = UIAction(title: "Change Video", image: UIImage(systemName: "video")) { _ in
            self.mediaHandlerAlert()
        }
        
        let deleteAction = UIAction(title: "Delete Entry", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.context.delete(self.selected!)
            do {
                try self.context.save()
            }
            catch {
                
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        let deleteMenu = UIMenu(
            title: "Delete Entry",
            image: UIImage(systemName: "trash"), options: .destructive, children: [deleteAction])
        
        if selected?.video != nil || selected != nil {
            let addMenuItems = UIMenu(image: nil, options: .displayInline, children: [saveAction, changeAction, deleteMenu])
            return addMenuItems
        }
        
        let addMenuItems = UIMenu(image: nil, options: .displayInline, children: [saveAction, changeAction, discardAction])
        return addMenuItems
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        journalEntriesController?.loadEntries()
        journalEntriesController?.journalTable.reloadData()
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
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if (journalText.text == "" || journalText.text == selected?.textDescription) &&
            (videoUrlHandler == nil || videoUrlHandler == selected?.video) {
            return true
        }
        return false
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.saveEntryAlert()
    }
    
    // Alert - Select Source
    @IBAction func selectSource(_ sender: Any) {
        
        if videoUrlHandler != nil {
            let player = AVPlayer(url: videoUrlHandler!)
            let vcPlayer = AVPlayerViewController()
            vcPlayer.player = player
            
            // Auto Play & Loop Video
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { (_) in
                player.seek(to: CMTime.zero)
                player.play()
            }
            
            self.present(vcPlayer, animated: true, completion: {
                vcPlayer.player?.play()
            })
        }
        if selected?.video == nil {
            mediaHandlerAlert()
        } else {
            
        }
    }
    
    // Update UI function
    func updateUI(){
        
        pageTitle.text = "#" + (selectedGroup?.title)!
        pageSubtitle.text = (selectedGroup?.subtitle)!
        
        selected == nil ? selectedIsNil() : selectedIsExist()
        
        if journalText.text.isEmpty {
            journalText.textColor = .lightGray
        }
        
        dateLabel.text = customDateFormatter(dateInput: selected?.date ?? Date())[0]
        monthLabel.text = customDateFormatter(dateInput: selected?.date ?? Date())[1]
        
        topNavView.layer.borderWidth = 1
        topNavView.layer.borderColor = UIColor.ColorLibrary.blackDynamic.withAlphaComponent(0.05).cgColor
        pageSubtitle.layer.masksToBounds = true
        pageSubtitle.layer.cornerRadius = 10
        mediaPlaceholder.clipsToBounds = true
        mediaPlaceholder.layer.cornerRadius = 10
        mediaPlaceholder.layer.borderWidth = 0.0
        journalText.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
    }
    
    func selectedIsNil(){
        playButton.isUserInteractionEnabled = true
        playButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
    }
    
    func selectedIsExist(){
        
        if selected?.video != nil {
            self.playButton.isUserInteractionEnabled = true
            self.playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        } else {
            self.playButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        }
        
        if (selected?.thumbnail) != nil {
            videoThumbnail.image = UIImage(data: (selected?.thumbnail)!)
        }
        journalText.text = selected?.textDescription
    }
    func mediaHandlerAlert(){
        let alert = UIAlertController(
            title: "Add Video",
            message: "Select media source.",
            preferredStyle: .alert)
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
                            title: "Save Changes",
                            style: UIAlertAction.Style.default,
                            handler: { action in
                                self.editEntryHandler = "Save"
                                self.checkAlertHandler()
                                self.performSegue(withIdentifier: "unwindToB", sender: self)
                            }))
        alert.addAction(UIAlertAction(
                            title: "Cancel",
                            style: UIAlertAction.Style.cancel,
                            handler: nil))
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
        textPlaceholder.layer.borderColor = UIColor.ColorLibrary.blackDynamic.withAlphaComponent(0.05).cgColor
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
            bottom: keyboardRect.height - (journalText.font!.lineHeight * 3),
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
            journalText.textColor = UIColor.ColorLibrary.blackDynamic
        }
        self.updateViewConstraints()
    }
}

extension UITextView {
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
