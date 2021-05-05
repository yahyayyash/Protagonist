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
    
    var gradient : CAGradientLayer?
        let gradientView : UIView = {
            let view = UIView()
            return view
        }()
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: CustomLabel!
    @IBOutlet weak var journalText: UITextView!
    @IBOutlet weak var mediaPlaceholder: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var textPlaceholder: RoundedCard!
    @IBOutlet weak var journalSubtitle: CustomLabel!
    
    let journalPlaceholderText: String = "Write down your thought here ... \nTap pencil icon to enable editing."
    
    let editedJournalPlaceholderText: String = "Tap here to start writing ..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        journalText.addDoneButtonOnKeyboard()
        
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
        } else {
            
        }
    }
    
    func updateUI(){
        
        selected == nil ? selectedIsNil() : selectedIsExist()
        
        setupClearNavbar()
        setupGradient()
        journalSubtitle.layer.cornerRadius = 10
        journalSubtitle.layer.masksToBounds = true
        
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
    
    func setupGradient() {
            let height : CGFloat = 125 // Height of the nav bar
        let color = UIColor(named: "whiteDynamic")!.withAlphaComponent(1.0).cgColor // You can mess with opacity to your liking
            let clear = UIColor(named: "whiteDynamic")!.withAlphaComponent(0.0).cgColor
            gradient = setupGradient(height: height, topColor: color,bottomColor: clear)
            view.addSubview(gradientView)
            NSLayoutConstraint.activate([
                gradientView.topAnchor.constraint(equalTo: view.topAnchor),
                gradientView.leftAnchor.constraint(equalTo: view.leftAnchor),
            ])
            gradientView.layer.insertSublayer(gradient!, at: 0)
        }
    
    func selectedIsNil(){
        self.title = "New Entry"
        self.journalSubtitle.text = selectedGroup?.subtitle
        
        playButton.isUserInteractionEnabled = false
        playButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
    }
    
    func selectedIsExist(){
        self.title = "#" + (selected?.journals?.title)!
        self.journalSubtitle.text = selected?.journals?.subtitle
        
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
        textPlaceholder.layer.borderColor = UIColor(named: "blackDynamic")?.withAlphaComponent(0.05).cgColor
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
            textPlaceholder.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
            mediaPlaceholder.layer.borderWidth = 1.0
            mediaPlaceholder.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
            
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
            journalText.textColor = UIColor(named: "blackDynamic")
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
