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
    var fetchController: NSFetchedResultsController<JournalEntry>!
    
    var selected: JournalData?
    var selectedContext: IndexPath?
    var entryList: [JournalEntry]?
    
    var gradient : CAGradientLayer?
        let gradientView : UIView = {
            let view = UIView()
            return view
        }()
    
    @IBOutlet weak var journalTable: UITableView!
    @IBOutlet weak var bottomGradient: UIView!
    @IBOutlet weak var buttonLabel: CustomLabel!
    @IBOutlet weak var journalSubtitle: CustomLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupClearNavbar()
        setupGradient()
        
        journalTable.rowHeight = UITableView.automaticDimension
        journalTable.estimatedRowHeight = 250
        
        let journalCell = UINib(nibName: EntryCell.identifier, bundle: nil)
        let headerCell = UINib(nibName: HeaderCell.identifier, bundle: nil)
        
        journalTable.register(journalCell, forCellReuseIdentifier: EntryCell.identifier)
        journalTable.register(headerCell, forCellReuseIdentifier: HeaderCell.identifier)
        
        journalTable.delegate = self
        journalTable.dataSource = self
    }
    
    // Unwind segue
    @IBAction func unwindToB(_ segue:UIStoryboardSegue){
        
    }
    
// MARK: - Fetch Entries, sort then group them.
    func loadEntries(){
        
        // Fetch entry list based on selected JournalData
        let entryRequest = JournalEntry.fetchRequest() as NSFetchRequest<JournalEntry>
        let name = selected?.title
        entryRequest.predicate = NSPredicate(format: "journals.title == %@", name!)
        
        // Sort fetched list by data
        let sort = NSSortDescriptor(key: "date", ascending: true)
        entryRequest.sortDescriptors = [sort]
        
        //
        fetchController = NSFetchedResultsController(fetchRequest: entryRequest, managedObjectContext: context, sectionNameKeyPath: "isoDate", cacheName: nil)
        
        do {
            try fetchController.performFetch()
            journalTable.reloadData()
        } catch {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEntries()
        interfaceUpdate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? EditorController
        switch segue.identifier {
        case "entrySegue":
            destination?.selected = fetchController.object(at: journalTable.indexPathForSelectedRow!)
            break
        case "editEntrySegue":
            destination?.selected = fetchController.object(at: selectedContext!)
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
    
// MARK: - UI Related Function
    
    func interfaceUpdate() {
        
        self.title = selected?.title
        self.journalSubtitle.text = selected?.subtitle
        
        let customImage = UIImage(systemName: "arrow.backward")
        let fontBig = UIFont(name:"Product Sans Bold", size:36)!
        let fontSmall = UIFont(name: "Product Sans Bold", size: 17)!
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menuItems())
        
        self.navigationController?.navigationBar.barTintColor = .clear
        self.navigationController?.navigationBar.backIndicatorImage = customImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = customImage
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.font: fontBig]
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: fontSmall]
        
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
    
    func menuItems() -> UIMenu {
        let addMenuItems = UIMenu(image: nil, options: .displayInline, children: [
            UIAction(title: "Edit Journal", image: UIImage(systemName: "pencil"), handler: { _ in
                
                let modalVC = AddJournalViewController()
                modalVC.modalPresentationStyle = .overCurrentContext
                modalVC.sourceView = "editEntry"
                modalVC.sourceJournal = self.selected
                modalVC.journalEntriesController = self
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
    
    func setupGradient() {
            let height : CGFloat = 150 // Height of the nav bar
        let color = UIColor.white.withAlphaComponent(1.0).cgColor // You can mess with opacity to your liking
            let clear = UIColor.white.withAlphaComponent(0.0).cgColor
            gradient = setupGradient(height: height, topColor: color,bottomColor: clear)
            view.addSubview(gradientView)
            NSLayoutConstraint.activate([
                gradientView.topAnchor.constraint(equalTo: view.topAnchor),
                gradientView.leftAnchor.constraint(equalTo: view.leftAnchor),
            ])
            gradientView.layer.insertSublayer(gradient!, at: 0)
        }
}


// MARK: - TableView Related Function
extension JournalEntriesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "entrySegue", sender: self)
    }
}

extension JournalEntriesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = journalTable.dequeueReusableCell(withIdentifier: HeaderCell.identifier) as! HeaderCell
        
        let fetchedObject = fetchController.sections?[section].objects?.first as! JournalEntry
        
        cell.dateLabel.text = customDateFormatter(dateInput: fetchedObject.date ?? Date())[0]
        cell.monthLabel.text = customDateFormatter(dateInput: fetchedObject.date ?? Date())[1]
        cell.contentView.clipsToBounds = false
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = fetchController {
            return frc.sections!.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = journalTable.dequeueReusableCell(withIdentifier: EntryCell.identifier, for: indexPath) as! EntryCell
        let currentJournal = fetchController.object(at: indexPath)
        
        if currentJournal.thumbnail != nil {
            cell.videoThumbnail.image = UIImage(data: currentJournal.thumbnail!)
            cell.playButton.isHidden = false
        } else {
            cell.videoThumbnail.image = UIImage(named: "")
            cell.playButton.isHidden = true
        }
        
        cell.textDescription.text = currentJournal.textDescription
        cell.dateLabel.text = customDateFormatter(dateInput: currentJournal.date ?? Date())[0]
        cell.monthLabel.text = customDateFormatter(dateInput: currentJournal.date ?? Date())[1]
        
        cell.selectionStyle = .none
        cell.clipsToBounds = false
        cell.contentView.clipsToBounds = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let index = indexPath.row
        let section = indexPath.section
        
        // 2
        let identifier = [index, section] as NSArray
        
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil) { _ in
            // 3
            let playAction = UIAction(
                title: "Play",
                image: UIImage(systemName: "play.rectangle")) { _ in
                let player = AVPlayer(url: self.fetchController.object(at: indexPath).video!)
                let vcPlayer = AVPlayerViewController()
                vcPlayer.player = player
                self.present(vcPlayer, animated: true, completion: nil)
            }
                
                // 4
            let editAction = UIAction(
                title: "Edit",
                image: UIImage(systemName: "pencil")) { _ in
                
                self.selectedContext = indexPath
                self.performSegue(withIdentifier: "editEntrySegue", sender: self)
            }
                
                let deleteConfirmation = UIAction(title: "Delete Entry", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    let entryToRemove = self.fetchController.object(at: indexPath)
                    self.context.delete(entryToRemove)
                    do {
                        try self.context.save()
                    }
                    catch {
                        
                    }
                    self.loadEntries()
                }
            
            let deleteAction = UIMenu(
                title: "Delete Entry",
                image: UIImage(systemName: "trash"), options: .destructive, children: [deleteConfirmation])
            
            if self.fetchController.object(at: indexPath).video != nil {
                return UIMenu(title: "", image: nil, children: [playAction, editAction, deleteAction])
            } else {
                return UIMenu(title: "", image: nil, children: [editAction, deleteAction])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard
            // 1
            let identifier = configuration.identifier as? Array<Int>,
            var index: Int? = identifier[0],
            var section: Int? = identifier[1],
            // 2
            let cell = tableView.cellForRow(at: IndexPath(row: index!, section: section!))
                as? EntryCell
        else {
            return nil
        }
        
        print(configuration.identifier)
        // 3
        return UITargetedPreview(view: cell.viewContainer)
    }
}

// MARK: - Other Function & Extension
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

extension UIViewController {
    func setupClearNavbar(){
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func setupGradient(height: CGFloat, topColor: CGColor, bottomColor: CGColor) ->  CAGradientLayer {
         let gradient: CAGradientLayer = CAGradientLayer()
         gradient.colors = [topColor,bottomColor]
         gradient.locations = [0.0 , 1.0]
         gradient.startPoint = CGPoint(x: 0.0, y: 0.25)
         gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
         gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: height)
         return gradient
    }
}
