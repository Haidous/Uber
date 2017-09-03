//
//  SelectDestinationViewController.swift
//  waselni
//
//  Created by Moussa on 8/31/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import UIKit
import GoogleMaps

class SelectDestinationViewController: UIViewController {
    
    @IBOutlet weak var selectView: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        selectView.transform = CGAffineTransform(translationX: 0, y: -selectView.frame.height)
        tableView.transform = CGAffineTransform(translationX: 0, y: tableView.frame.height)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.5) {
            self.selectView.transform = .identity
            self.tableView.transform = .identity
        }
        
        
    }
    
}
extension SelectDestinationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            locationManager.stopUpdatingLocation()
        }
        
    }
}
