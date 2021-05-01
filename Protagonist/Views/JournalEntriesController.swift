//
//  JournalEntriesController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 29/04/21.
//

import UIKit
import CoreData
import AVKit

class JournalEntriesController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selected: JournalData?
    var selectedContext: Int?
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menuItems())
        interfaceUpdate()
    }
    
    func fetchEntries(){
        do {
            let entryRequest = JournalEntry.fetchRequest() as NSFetchRequest<JournalEntry>
            let name = selected?.title
            entryRequest.predicate = NSPredicate(format: "journals.title == %@", name!)
            self.entryList = try context.fetch(entryRequest)
            
            journalTable.reloadData()
        }
        catch {
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.layoutIfNeeded()
        
        fetchEntries()
        interfaceUpdate()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? EditorController
        switch segue.identifier {
        case "entrySegue":
            let selectedRow = journalTable.indexPathForSelectedRow?.row
            destination?.selected = entryList![selectedRow! - 1]
            break
        case "editEntrySegue":
            destination?.selected = entryList![selectedContext! - 1]
            destination?.isEditRightAway = true
            break
        case "newEntrySegue":
            destination?.selected = nil
            destination?.selectedGroup = selected!
            break
        case .none:
            break
        case .some(_):
            break
        }
        
    }
    
    func menuItems() -> UIMenu {
        let addMenuItems = UIMenu(image: nil, options: .displayInline, children: [
            UIAction(title: "Edit Journal", image: UIImage(systemName: "pencil"), handler: { _ in
                
                let modalVC = AddJournalViewController()
                modalVC.modalPresentationStyle = .overCurrentContext
                modalVC.sourceView = "editEntry"
                modalVC.sourceJournal = self.selected
                self.present(modalVC, animated: true, completion: nil)
                
            }),
            UIAction(title: "Delete Journal", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in
                let alert = UIAlertController(
                    title: "Delete \"\(self.selected?.title ?? "Journal")\" ?",
                    message: "This will delete all entries in this journal.",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(
                                    title: "Delete",
                                    style: UIAlertAction.Style.destructive,
                                    handler: { action in
                                        self.performSegue(withIdentifier: "unwindToA", sender: self)
                                        let journalToRemove = self.selected
                                        self.context.delete(journalToRemove!)
                                        
                                        do {
                                            try self.context.save()
                                        }
                                        catch{}
                                    }))
                alert.addAction(UIAlertAction(
                                    title: "Cancel",
                                    style: UIAlertAction.Style.cancel,
                                    handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        ])
        
        return addMenuItems
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
            
            if currentJournal.thumbnail != nil {
                cell.videoThumbnail.image = UIImage(data: currentJournal.thumbnail!)
            } else {
                cell.videoThumbnail.image = UIImage(named: "")
                cell.playButton.isHidden = true
            }
            
            cell.textDescription.text = currentJournal.textDescription
            cell.dateLabel.text = customDateFormatter(dateInput: currentJournal.date ?? Date())[0]
            cell.monthLabel.text = customDateFormatter(dateInput: currentJournal.date ?? Date())[1]
            
            cell.selectionStyle = .none
            
            return cell
        }
        let cell = journalTable.dequeueReusableCell(withIdentifier: SubtitleCell.identifier) as! SubtitleCell
        
        cell.subtitleCell.text = selected?.subtitle
        
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
                    let player = AVPlayer(url: self.entryList![index - 1].video!)
                    let vcPlayer = AVPlayerViewController()
                    vcPlayer.player = player
                    self.present(vcPlayer, animated: true, completion: nil)
                }
                    
                    // 4
                let editAction = UIAction(
                    title: "Edit",
                    image: UIImage(systemName: "pencil")) { _ in
                    
                    self.selectedContext = index
                    self.performSegue(withIdentifier: "editEntrySegue", sender: self)
                }
                    
                    let deleteConfirmation = UIAction(title: "Delete Entry", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                        let entryToRemove = self.entryList![index - 1]
                        self.context.delete(entryToRemove)
                        do {
                            try self.context.save()
                        }
                        catch {
                            
                        }
                        self.fetchEntries()
                    }
                
                let deleteAction = UIMenu(
                    title: "Delete Entry",
                    image: UIImage(systemName: "trash"), options: .destructive, children: [deleteConfirmation])
                    
                    if self.entryList![index - 1].video != nil {
                        return UIMenu(title: "", image: nil, children: [playAction, editAction, deleteAction])
                    } else {
                        return UIMenu(title: "", image: nil, children: [editAction, deleteAction])
                    }
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

func customDateFormatter(dateInput: Date) -> [String] {
    var date = ""
    var month = ""
    
    let dayFormatter = DateFormatter()
    dayFormatter.setLocalizedDateFormatFromTemplate("dd")
    date = dayFormatter.string(from: dateInput)
    
    let monthFormatter = DateFormatter()
    monthFormatter.setLocalizedDateFormatFromTemplate("MMM")
    month = monthFormatter.string(from: dateInput)
    
    return [date, month]
}
