//
//  FancyTextfield.swift
//  waselni
//
//  Created by Moussa on 8/30/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import UIKit

@IBDesignable
class FancyTextField: UITextField{
    
    @IBInspectable var paddingLeft: CGFloat = 0
    @IBInspectable var paddingRight: CGFloat = 0
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        
        didSet{
            
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
            
        }
        
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        
        didSet{
            
            layer.borderWidth = borderWidth
            
        }
        
    }
    
    @IBInspectable var borderColor: UIColor?{
        
        didSet{
            
            layer.borderColor = borderColor?.cgColor
            
        }
        
    }
    
    @IBInspectable var _backgroundColor: UIColor?{
        
        didSet{
            
            backgroundColor = _backgroundColor
            
        }
        
    }
    
    @IBInspectable var placeholderColor: UIColor?{
        
        didSet{
            
            let rawString = attributedPlaceholder != nil ? attributedPlaceholder!.string : ""
            let str = NSAttributedString(string: rawString, attributes: [NSForegroundColorAttributeName: placeholderColor!])
            attributedPlaceholder = str
            
        }
        
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + paddingLeft, y: bounds.origin.y, width: bounds.size.width - paddingLeft - paddingRight, height: bounds.size.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
}
