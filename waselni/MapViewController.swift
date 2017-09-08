//
//  MapViewController.swift
//  waselni
//
//  Created by Moussa on 8/30/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    
    @IBOutlet weak var estimationView: UIVisualEffectView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var estimatedTimeLabel: UILabel!
    @IBOutlet weak var estimatedDistanceLabel: UILabel!
    @IBOutlet weak var costOfRideLabel: UILabel!
    
    @IBOutlet weak var selectView: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fromTextField: FancyTextField!
    @IBOutlet weak var toTextField: FancyTextField!
    
    @IBOutlet weak var currentLocationImage: UIImageView!
    
    let locationManager = CLLocationManager()
    
    var placesClient:GMSPlacesClient!
    
    var longitude:Double?
    var latitude:Double?
    
    var destination:CLLocationCoordinate2D?
    
    var distanceText:String?
    var timeText:String?
    
    var placesDictionary = [String:[String]]()
    
    var placeIDArray = [String]()
    var placeNameArray = [String]()
    var placeAddressArray = [String]()
    var placeCoordinatesArray = [CLLocationCoordinate2D]()
    
    var likelihoodsNameArray = [String]()
    var likelihoodsAddressArray = [String]()
    var likelihoodsCoordinatesArray = [CLLocationCoordinate2D]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fromTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        toTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fromTextField.delegate = self
        toTextField.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        createBikeMarkers()
        getLikelihoodPlaces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        toggleSelectionViews(toggle: false)
        toggleEstimationView(toggle: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser == nil {
            
            performSegue(withIdentifier: "toLogin", sender: nil)
            
        }
        
    }
    
    func createBikeMarkers(){
    
        MapService.instance.createBikeMarkers(mapView: mapView)
        
    }
    
    func getPlaceInformation(textField:UITextField){
    
        MapService.instance.placeAutocomplete(mapView: mapView, textField: textField, onComplete: { (error, data) in
            
            if let placeIDArray = data{
                
                MapService.instance.getPlaceInformation(placeIDArray: placeIDArray as! [String], onComplete: {(error, data) in
                    
                    if let placeInformationArray = data as? [Any]{
                        
                        self.placeNameArray = placeInformationArray[0] as! [String]
                        self.placeAddressArray = placeInformationArray[1] as! [String]
                        self.placeCoordinatesArray = placeInformationArray[2] as! [CLLocationCoordinate2D]
                        
                        DispatchQueue.main.async {
                            
                            self.tableView.reloadData()
                            
                        }
                        
                    }
                    
                })
            }
        })
    }
    
    func getLikelihoodPlaces(){
        
        MapService.instance.getLikelihoodPlaces(onComplete: {(error, data) in
        
            if let likelihoodInformation = data as? [Any]{
            
                self.likelihoodsNameArray = likelihoodInformation[0] as! [String]
                self.likelihoodsAddressArray = likelihoodInformation[1] as! [String]
                self.likelihoodsCoordinatesArray = likelihoodInformation[2] as! [CLLocationCoordinate2D]
            
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                }
                
            }
        
        })
    }
    
    func toggleSelectionViews(toggle: Bool){
    
        if toggle{
        
            UIView.animate(withDuration: 0.5) {
                self.selectView.transform = .identity
                self.tableView.transform = .identity
            }
            
        }else{
        
            UIView.animate(withDuration: 0.5) {
                
                self.selectView.transform = CGAffineTransform(translationX: 0, y: -self.selectView.frame.height)
                self.tableView.transform = CGAffineTransform(translationX: 0, y: self.tableView.frame.height)
                
            }
        
        }
    
    }
    
    func toggleEstimationView(toggle: Bool){
    
    
        if toggle{
        
            UIView.animate(withDuration: 0.5, animations: { 
                
                self.cancelButton.alpha = 1
                self.estimationView.transform = .identity
                
            })
        
        }else{
        
            UIView.animate(withDuration: 0.5, animations: { 
                
                self.estimationView.transform = CGAffineTransform(translationX: 0, y: self.estimationView.frame.height)
                self.cancelButton.alpha = 0

                
            })
        
        }
    
    }
    
    @IBAction func textfieldTapped(_ sender: UITapGestureRecognizer) {
        
        toggleSelectionViews(toggle: true)
        visualEffectView.alpha = 0
        
    }

    @IBAction func signOutClicked(_ sender: Any) {
        
        do {
            
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toLogin", sender: nil)
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
            
        }
        
    }
    
    @IBAction func waselniButtonClicked(_ sender: Any) {
        
        let currentLocation = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        self.cancelButton.alpha = 0
        
        DataService.instance.uploadCUDestinationCoords(latitude: (destination?.latitude)!, longitude: (destination?.longitude)!)
        DataService.instance.uploadCDDestinationCoords(latitude: latitude!, longitude: longitude!)
        DataService.instance.getActiveDriverCoords { (error, data) in
            
            let activeDriverCoords = data as! CLLocationCoordinate2D
            
            MapService.instance.getDirections(mapView: self.mapView, origin: currentLocation, destination: activeDriverCoords, onComplete: nil)
            
        }
        createBikeMarkers()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        
        toggleEstimationView(toggle: false)
        
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.alpha = 1
        }
        
        self.fromTextField.text = ""
        self.toTextField.text = ""
        self.tableView.reloadData()
        mapView.clear()
        createBikeMarkers()
        
    }
}

extension MapViewController: CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

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
            
            self.longitude = location.coordinate.longitude
            self.latitude = location.coordinate.latitude
            
            DataService.instance.uploadCUCurrentLocationCoords(latitude: self.latitude!, longitude: self.longitude!)
            
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectLocationCell") as! LocationCell
        
        if self.placeNameArray.isEmpty || indexPath.row > placeNameArray.count - 1{
        
            cell.locationName.text = likelihoodsNameArray[indexPath.row]
            cell.locationAddress.text = likelihoodsAddressArray[indexPath.row]
            
            return cell
        
        }else{
        
            cell.locationName.text = placeNameArray[indexPath.row]
            cell.locationAddress.text = placeAddressArray[indexPath.row]
            
            return cell
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if placeNameArray.isEmpty{
            
            return likelihoodsNameArray.count
            
        }else{
            
            return placeNameArray.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60.0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let myCurrentLocation = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
    
        
        if fromTextField.text == "" && toTextField.text == ""{
        
            destination = likelihoodsCoordinatesArray[indexPath.row]
            
            mapView.camera = GMSCameraPosition(target: destination!, zoom: 15, bearing: 0, viewingAngle: 0)
            
            let marker = GMSMarker()
            mapView.clear()
            marker.position = destination!
            marker.title = likelihoodsNameArray[indexPath.row]
            marker.map = mapView
            
        }else{
            
            destination = placeCoordinatesArray[indexPath.row]
            
            mapView.camera = GMSCameraPosition(target: destination!, zoom: 15, bearing: 0, viewingAngle: 0)
            
            let marker = GMSMarker()
            mapView.clear()
            marker.position = destination!
            marker.title = placeNameArray[indexPath.row]
            marker.map = mapView
        
            self.placeAddressArray.removeAll()
            self.placeNameArray.removeAll()
            self.placeIDArray.removeAll()

            tableView.reloadData()
            
        }

        toggleSelectionViews(toggle: false)
        
        toggleEstimationView(toggle: true)
        
        self.fromTextField.resignFirstResponder()
        self.toTextField.resignFirstResponder()
        
        
        MapService.instance.getDirections(mapView: mapView, origin: myCurrentLocation, destination: destination!, onComplete: nil)
        createBikeMarkers()
        MapService.instance.estimateDistanceAndTime(origin: myCurrentLocation, destination: destination!, onComplete: {(error, data) in
        
            let estimation = data as! [Any]
            
            let distanceText = estimation[0]
            let timeText = estimation[1]
            
            self.distanceText = String(describing: distanceText)
            self.timeText = String(describing: timeText)
            
            self.estimatedDistanceLabel.text = "\(distanceText)"
            self.estimatedTimeLabel.text = "E.T.A \(timeText)"
            self.cancelButton.alpha = 1
        
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        fromTextField.resignFirstResponder()
        toTextField.resignFirstResponder()
    
        let contentYoffset = scrollView.contentOffset.y
        if contentYoffset < -100.0{
        
            toggleSelectionViews(toggle: false)
            UIView.animate(withDuration: 0.5, animations: {
                
                self.visualEffectView.alpha = 1
                
            })
        
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if self.currentLocationImage.alpha == 1{
        
            UIView.animate(withDuration: 0.3, animations: { 
                
                self.currentLocationImage.alpha = 0
                
            })
        
        }
        
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if textField.text != nil{
            
            getPlaceInformation(textField: textField)
            
        }
    }
    
    
}

func removeDuplicates<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
    
    var buffer = [T]()
    var added = Set<T>()
    for elem in source {
        if !added.contains(elem) {
            buffer.append(elem)
            added.insert(elem)
        }
    }
    return buffer
    
}

