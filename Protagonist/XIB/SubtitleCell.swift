//
//  SubtitleCell.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 30/04/21.
//

import UIKit

class SubtitleCell: UITableViewCell {
    static let identifier = "subtitleCell"
    @IBOutlet weak var subtitleCell: CustomLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
