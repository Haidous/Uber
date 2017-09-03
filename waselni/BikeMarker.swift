//
//  BikeMarker.swift
//  waselni
//
//  Created by Moussa on 8/30/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import UIKit
import GoogleMaps

class BikeMarker: GMSMarker {
    
    init(position: CLLocationCoordinate2D, mapView: GMSMapView) {
        super.init()
        
        self.position = position
        self.map = mapView
        self.icon = UIImage(named: "bikeIcon")
        
    }

}
