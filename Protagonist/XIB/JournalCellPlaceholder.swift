//
//  JournalCellPlaceholder.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 29/04/21.
//

import UIKit

class JournalCellPlaceholder: UICollectionViewCell {

    static let identifier = "JournalCellPlaceholder"
    
    @IBOutlet weak var cellNumber: UILabel!
    @IBOutlet weak var journalName: UILabel!
    @IBOutlet weak var journalDescription: UILabel!
    @IBOutlet weak var journalThumbnail: UIImageView!
    @IBOutlet weak var lastUpdate: UILabel!
    @IBOutlet weak var textLast: UILabel!
    @IBOutlet weak var imagePlaceholder: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 10
        self.journalThumbnail.layer.masksToBounds = true
        self.journalThumbnail.layer.cornerRadius = 10
        
        lastUpdate.layer.shadowColor = UIColor.black.cgColor
        lastUpdate.layer.shadowRadius = 10.0
        lastUpdate.layer.shadowOpacity = 0.5
        
        textLast.layer.shadowColor = UIColor.black.cgColor
        textLast.layer.shadowRadius = 10.0
        textLast.layer.shadowOpacity = 0.5
    }

}
