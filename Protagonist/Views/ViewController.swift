//
//  ViewController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 28/04/21.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var journalList: [JournalData]?
    
    @IBOutlet weak var journalCollection: UICollectionView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var addJournal: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var buttonLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gender = UserDefaults.standard.value(forKey: "Gender")
        avatarImage.image = UIImage(named: "\(gender ?? "male")-avatar")
        backgroundImage.image = UIImage(named: "\(gender ?? "male")-full")
        let user = UserDefaults.standard.value(forKey: "Username")
        userName.text = user as? String
        
        let journalCell = UINib(nibName: JournalCell.identifier, bundle: nil)
        let journalPlaceholder = UINib(nibName: JournalCellPlaceholder.identifier, bundle: nil)
        
        journalCollection.register(journalCell, forCellWithReuseIdentifier: JournalCell.identifier)
        journalCollection.register(journalPlaceholder, forCellWithReuseIdentifier: JournalCellPlaceholder.identifier)
        
        journalCollection.delegate = self
        journalCollection.dataSource = self
        
    }
    
    @IBAction func segueModal(_ sender: Any) {
        let modalVC = AddJournalViewController()
        modalVC.modalPresentationStyle = .overCurrentContext
        modalVC.sourceView = "createEntry"
        modalVC.selectedView = self
        present(modalVC, animated: true, completion: nil)
    }
    
    @IBAction func unwindToA(_ segue:UIStoryboardSegue){
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCellsLayout()
    }
    
    func fetchJournal(){
        do {
            self.journalList = try context.fetch(JournalData.fetchRequest())
            
            DispatchQueue.main.async {
                self.journalCollection.reloadData()
            }
        }
        catch {
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.fetchJournal()
        self.checkJournalList()
        cellLayoutRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? JournalEntriesController
        self.fetchJournal()
        switch segue.identifier {
        case "journalSegue":
            let selectedRow = journalCollection.indexPathsForSelectedItems?[0].row ?? 0
            destination?.selected = journalList?[selectedRow]
            break
        case "latestSegue":
            destination?.selected = journalList?.last
            break
        case .none:
            break
        case .some(_):
            break
        }
    }
    
    func checkJournalList() {
        if (journalList?.count ?? 0) > 0{
            backgroundImage.isHidden = true
            avatarImage.isHidden = false
            buttonLabel.textColor = UIColor(named: "blackDynamic")
        } else {
            backgroundImage.isHidden = false
            avatarImage.isHidden = true
            buttonLabel.textColor = .white
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellLayoutRefresh()
        performSegue(withIdentifier: "journalSegue", sender: self)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func cellLayoutRefresh(){
        // An improper way to fix cells not updating after selecting the cell or back from other page
        DispatchQueue.main.async {
            self.journalCollection.setContentOffset(CGPoint(x: self.journalCollection.contentOffset.x - 1, y: 0), animated: true)
        }
    }
    
    func updateCellsLayout(){
        let centerX = journalCollection.contentOffset.x + (journalCollection.frame.size.width)/2
        
        for cell in journalCollection.visibleCells {
            var offsetX = centerX - cell.center.x
            if offsetX < 0 {
                offsetX *= -1
            }
            cell.transform = CGAffineTransform.identity
            let offsetPercentage = offsetX / (view.bounds.width * 2.7)
            let scaleX = 1 - (offsetPercentage / 2)
            cell.transform = CGAffineTransform(scaleX: scaleX, y: scaleX)
            cell.alpha = 1 - (offsetPercentage * 2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (journalList?.count ?? 0) > 0 {
            return journalList!.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (journalList?.count ?? 0) > 0 {
            let cell = journalCollection.dequeueReusableCell(withReuseIdentifier: JournalCellPlaceholder.identifier, for: indexPath) as! JournalCellPlaceholder
            let currentJournal = journalList?[indexPath.row]
            let lastEntry = currentJournal?.entries?.lastObject as? JournalEntry
            
            // Check if there's thumbnail on the last object of current journal
            if lastEntry?.thumbnail != nil {
                cell.journalThumbnail.image = UIImage(data: (lastEntry?.thumbnail)!)
                cell.lastUpdate.text = lastEntry?.isoDate
                cell.lastUpdate.isHidden = false
                cell.textLast.isHidden = false
                cell.gradientBottom.isHidden = false
                cell.cellNumber.isHidden = false
            } else {
                cell.journalThumbnail.image = UIImage(named: "both-colored")
                cell.lastUpdate.isHidden = true
                cell.textLast.isHidden = true
                cell.cellNumber.isHidden = true
                cell.gradientBottom.isHidden = true
            }
            
            // Check the journal bookmark state
            if (currentJournal?.isBookmarked)! {
                cell.bookmarkIcon.isHidden = false
            } else {
                cell.bookmarkIcon.isHidden = true
            }
            
            (journalList?.count ?? 0 < 10) ? (cell.cellNumber.text = "0\(indexPath.row + 1)") :  (cell.cellNumber.text = "\(indexPath.row + 1)")
            
            cell.journalName.text = "#" + (currentJournal?.title)!
            cell.journalDescription.text = currentJournal?.subtitle
            return cell
        }
        let cell = journalCollection.dequeueReusableCell(withReuseIdentifier: JournalCell.identifier, for: indexPath) as! JournalCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: journalCollection.frame.width - 80, height: journalCollection.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCellsLayout()
    }
}

// MARK: - UICollectionViewFlowLayout

class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint
    {
        if let collectionViewBounds = self.collectionView?.bounds
        {
            let halfWidthOfVC = collectionViewBounds.size.width * 0.5
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidthOfVC
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: collectionViewBounds)
            {
                var candidateAttribute : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells
                {
                    let candAttr : UICollectionViewLayoutAttributes? = candidateAttribute
                    if candAttr != nil
                    {
                        let a = attributes.center.x - proposedContentOffsetCenterX
                        let b = candAttr!.center.x - proposedContentOffsetCenterX
                        if abs(a) < abs(b)
                        {
                            candidateAttribute = attributes
                        }
                    }
                    else
                    {
                        candidateAttribute = attributes
                        continue
                    }
                }
                
                if candidateAttribute != nil
                {
                    return CGPoint(x: candidateAttribute!.center.x - halfWidthOfVC, y: proposedContentOffset.y);
                }
            }
        }
        return CGPoint.zero
    }
}
