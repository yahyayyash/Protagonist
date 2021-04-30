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
    @IBOutlet weak var contextMenu: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 10
    }

}
