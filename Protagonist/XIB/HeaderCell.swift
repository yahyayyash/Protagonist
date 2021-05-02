//
//  HeaderCell.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 02/05/21.
//

import UIKit

class HeaderCell: UITableViewCell {

    static let identifier = "HeaderCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: CustomLabel!
    @IBOutlet weak var backgroundHeader: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
