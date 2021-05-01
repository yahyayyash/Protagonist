//
//  EntryCell.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 29/04/21.
//

import UIKit

class EntryCell: UITableViewCell {

    static let identifier = "EntryCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var mediaPlaceholder: UIView!
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var textDescription: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mediaPlaceholder.layer.cornerRadius = 5
        mediaPlaceholder.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

