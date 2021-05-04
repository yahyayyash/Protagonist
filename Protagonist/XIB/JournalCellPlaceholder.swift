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
    @IBOutlet weak var gradientBottom: UIView!
    @IBOutlet weak var thumbnailPlaceholder: UIView!
    @IBOutlet weak var bookmarkIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let gradient: CAGradientLayer = {
            let gradient = CAGradientLayer()
            gradient.type = .axial
            gradient.colors = [
                UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
                UIColor(red: 0, green: 0, blue: 0, alpha: 0.75).cgColor
            ]
            gradient.locations = [0, 1]
            return gradient
        }()
        
        gradient.frame = gradientBottom.bounds
        gradientBottom.layer.addSublayer(gradient)
        
        self.layer.cornerRadius = 10
        self.thumbnailPlaceholder.layer.borderColor = UIColor(named: "black")?.cgColor
        self.thumbnailPlaceholder.layer.borderWidth = 2.5
        self.thumbnailPlaceholder.layer.cornerRadius = 5
        self.thumbnailPlaceholder.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

}
