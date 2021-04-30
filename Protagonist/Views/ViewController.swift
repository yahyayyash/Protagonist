//
//  ViewController.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 28/04/21.
//

import UIKit
import Foundation

class ViewController: UIViewController, testPassing {
    
    //    Testing with no journal entry condition
    //    var journalList = [JournalData]()
    var journalList = DatabaseDummy.shared.getJournals()
    
    @IBOutlet weak var journalCollection: UICollectionView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var addJournal: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let journalCell = UINib(nibName: JournalCell.identifier, bundle: nil)
        let journalPlaceholder = UINib(nibName: JournalCellPlaceholder.identifier, bundle: nil)
        
        journalCollection.register(journalCell, forCellWithReuseIdentifier: JournalCell.identifier)
        journalCollection.register(journalPlaceholder, forCellWithReuseIdentifier: JournalCellPlaceholder.identifier)
        
        journalCollection.delegate = self
        journalCollection.dataSource = self
        
    }
    
    @IBAction func segueModal(_ sender: Any) {
        let modalVC = AddJournalViewController()
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .overCurrentContext
        present(modalVC, animated: true, completion: nil)
    }
    
    func testPrint() {
        print("It's working.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        journalList = DatabaseDummy.shared.getJournals()
        journalCollection.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? JournalEntriesController
        journalList = DatabaseDummy.shared.getJournals()
        switch segue.identifier {
        case "journalSegue":
            let selectedRow = journalCollection.indexPathsForSelectedItems?[0].row
            destination?.selected = journalList[selectedRow!]
            break
        case "latestSegue":
            destination?.selected = journalList.last
            break
        case .none:
            break
        case .some(_):
            break
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "journalSegue", sender: self)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if journalList.count > 0 {
            return journalList.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if journalList.count > 0 {
            let cell = journalCollection.dequeueReusableCell(withReuseIdentifier: JournalCellPlaceholder.identifier, for: indexPath) as! JournalCellPlaceholder
            let currentJournal = journalList[indexPath.row]
            
            cell.cellNumber.text = "0\(indexPath.row + 1)"
            cell.journalName.text = currentJournal.title
            cell.journalDescription.text = currentJournal.description
            return cell
        }
        let cell = journalCollection.dequeueReusableCell(withReuseIdentifier: JournalCell.identifier, for: indexPath) as! JournalCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: journalCollection.frame.width - 80, height: journalCollection.frame.height)
    }
}

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

protocol testPassing {
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

