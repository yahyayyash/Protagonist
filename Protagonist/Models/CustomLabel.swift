//
//  LabelUnderline.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 29/04/21.
//

import UIKit

@IBDesignable class CustomLabel: UILabel {
    
    var underline: CGFloat = 0.0
    var underlinePosition: CGFloat = 0.0
    var underlineRadius: CGFloat = 0.0
    
    var textEdgeInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textEdgeInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textEdgeInsets))
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: self.frame.height - underlinePosition, width: self.frame.width, height: underline), cornerRadius: underlineRadius)
        UIColor.systemYellow.setFill()
        path.fill()
        super.draw(rect)
    }
    
    @IBInspectable
    var paddingLeft: CGFloat {
        set { textEdgeInsets.left = newValue }
        get { return textEdgeInsets.left }
    }
    
    @IBInspectable
    var paddingRight: CGFloat {
        set { textEdgeInsets.right = newValue }
        get { return textEdgeInsets.right }
    }
    
    @IBInspectable
    var paddingTop: CGFloat {
        set { textEdgeInsets.top = newValue }
        get { return textEdgeInsets.top }
    }
    
    @IBInspectable
    var paddingBottom: CGFloat {
        set { textEdgeInsets.bottom = newValue }
        get { return textEdgeInsets.bottom }
    }
    
    @IBInspectable
    var underlineHeight: CGFloat {
        set { underline = newValue }
        get { return underline }
    }
    
    @IBInspectable
    var offset: CGFloat {
        set { underlinePosition = newValue }
        get { return underlinePosition }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        set { underlineRadius = newValue }
        get { return underlineRadius }
    }
}
