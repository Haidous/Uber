//
//  Location.swift
//  waselni
//
//  Created by Moussa on 8/31/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import Foundation

struct Location {

    private var _name: String
    private var _address: String
    private var _latitude:Float
    private var _longitude:Float

    var name:String {
    
        return _name
    
    }
    
    var address:String {
    
        return _address
        
    }
    
    var latitude:Float {
    
        return _latitude
        
        
    }
    
    var longitude:Float{
    
        return _longitude
    
    }
    
    init(name:String, address:String, latitude:Float, longitude:Float){
    
        _name = name
        _address = address
        _latitude = latitude
        _longitude = longitude
    
    }
    
}
