//
//  GenericButton.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 30/04/21.
//

import UIKit

class GenericButton: UIButton {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        self.setTitleColor(UIColor.ColorLibrary.accentColor, for: .normal)
        self.setTitleColor(UIColor.ColorLibrary.accentColor.withAlphaComponent(0.5), for: .highlighted)
        self.setTitleColor(UIColor.ColorLibrary.accentColor.withAlphaComponent(0.5), for: .disabled)
    }
    
}
