//
//  FancyImageView.swift
//  waselni
//
//  Created by Moussa on 8/30/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import UIKit

@IBDesignable
class FancyImageView: UIImageView{
    
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
    
}
