//
//  JournalEntriesController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 29/04/21.
//

import UIKit

class JournalEntriesController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selected: JournalData?
    var entryList: [JournalEntry]?
    
    @IBOutlet weak var journalTable: UITableView!
    @IBOutlet weak var bottomGradient: UIView!
    @IBOutlet weak var buttonLabel: CustomLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        journalTable.rowHeight = UITableView.automaticDimension
        journalTable.estimatedRowHeight = 250
        
        let journalCell = UINib(nibName: EntryCell.identifier, bundle: nil)
        journalTable.register(journalCell, forCellReuseIdentifier: EntryCell.identifier)
        
        journalTable.delegate = self
        journalTable.dataSource = self
        
        interfaceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.layoutIfNeeded()
        
        if selected != nil {
            entryList = DatabaseDummy.shared.getEntriesByJournal(journal: selected!)
        }
        
        journalTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? EditorController
        let selectedRow = journalTable.indexPathForSelectedRow?.row
        destination?.selected = entryList![selectedRow! - 1]
    }
    
    func interfaceUpdate() {
        let customImage = UIImage(systemName: "arrow.backward")
        let fontBig = UIFont(name:"Product Sans Bold", size:36)!
        let fontSmall = UIFont(name: "Product Sans Bold", size: 17)!
        
        self.navigationController?.navigationBar.backIndicatorImage = customImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = customImage
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.font: fontBig]
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: fontSmall]
        
        self.title = selected?.title
        
        let gradient: CAGradientLayer = {
            let gradient = CAGradientLayer()
            gradient.type = .axial
            gradient.colors = [
                UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor,
                UIColor.white.cgColor
            ]
            gradient.locations = [0, 1]
            return gradient
        }()
        
        gradient.frame = bottomGradient.bounds
        bottomGradient.layer.addSublayer(gradient)
        
        buttonLabel.backgroundColor = .systemYellow
        buttonLabel.layer.cornerRadius = 10
        buttonLabel.layer.masksToBounds = true
    }
}

extension JournalEntriesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "entrySegue", sender: self)
    }
}

extension JournalEntriesController: UITableViewDataSource {
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        let now = Date()
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateFormat = "LLLL"
    //        let nameOfMonth = dateFormatter.string(from: now)
    //
    //        return nameOfMonth
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if entryList != nil {
            return (entryList!.count + 1)
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > 0 {
            let cell = journalTable.dequeueReusableCell(withIdentifier: EntryCell.identifier, for: indexPath) as! EntryCell
            let currentJournal = entryList![indexPath.row - 1]
            
            cell.videoThumbnail.image = currentJournal.thumbnail
            cell.textDescription.text = currentJournal.textDescription
            cell.selectionStyle = .none
            
            return cell
        }
        let cell = journalTable.dequeueReusableCell(withIdentifier: SubtitleCell.identifier) as! SubtitleCell
        
        cell.subtitleCell.text = selected?.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = UIView()
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        if indexPath.row > 0 {
            // 1
            let index = indexPath.row
            
            // 2
            let identifier = "\(index)" as NSString
            
            return UIContextMenuConfiguration(
                identifier: identifier,
                previewProvider: nil) { _ in
                // 3
                let playAction = UIAction(
                    title: "Play",
                    image: UIImage(systemName: "play.rectangle")) { _ in
                    print("Map Action")
                }
                    
                    // 4
                let editAction = UIAction(
                    title: "Edit",
                    image: UIImage(systemName: "pencil")) { _ in
                    print("Share Action")
                }
                    
                    let deleteAction = UIAction(
                        title: "Delete",
                        image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                        print("Delete Action")
                    }
                    
                    // 5
                return UIMenu(title: "", image: nil, children: [playAction, editAction, deleteAction])
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard
            // 1
            let identifier = configuration.identifier as? String,
            let index = Int(identifier),
            // 2
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
                as? EntryCell
        else {
            return nil
        }
        
        // 3
        return UITargetedPreview(view: cell.viewContainer)
    }
}


