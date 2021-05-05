//
//  RoundedCard.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 29/04/21.
//

import UIKit

class RoundedCard: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.borderColor = UIColor.ColorLibrary.blackStatic.withAlphaComponent(0.1).cgColor
        layer.cornerRadius = 10
        layer.masksToBounds = false
        
        layer.borderWidth = 1.0
        layer.shadowColor = UIColor.ColorLibrary.blackStatic.cgColor
        layer.shadowRadius = 15.0
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        
    }
}

class GenericTextView: UITextView {
    var lineHeight: CGFloat = 18.0
    
    override var font: UIFont? {
        didSet {
            if let newFont = font {
                lineHeight = newFont.lineHeight
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor.ColorLibrary.blackStatic.withAlphaComponent(0.1).cgColor)
        let numberOfLines = Int(rect.height / lineHeight)
        let topInset = textContainerInset.top
        
        for i in 1...numberOfLines {
            let y = topInset + CGFloat(i) * lineHeight
            
            let line = CGMutablePath()
            line.move(to: CGPoint(x: 0.0, y: y))
            line.addLine(to: CGPoint(x: rect.width, y: y))
            ctx?.addPath(line)
        }
        
        ctx?.strokePath()
        
        super.draw(rect)
    }
}
