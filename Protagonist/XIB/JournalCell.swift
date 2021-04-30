//
//  journalCell.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 28/04/21.
//

import UIKit

class JournalCell: UICollectionViewCell {
    
    static let identifier = "JournalCell"

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundImage.image = UIImage(named: "ornament-1")
        self.layer.cornerRadius = 10
    }

}
