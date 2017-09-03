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
    
    @IBOutlet weak var selectView: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fromTextField: FancyTextField!
    @IBOutlet weak var toTextField: FancyTextField!
    
    @IBOutlet weak var currentLocationImage: UIImageView!
    
    let locationManager = CLLocationManager()
    
    var placesClient:GMSPlacesClient!
    
    var longitude:Double?
    var latitude:Double?
    
    var placesDictionary = [String:[String]]()
    
    var placeIDArray = [String]()
    var placeNameArray = [String]()
    var placeAddressArray = [String]()
    var placeCoordinatesArray = [CLLocationCoordinate2D]()
    
    var likelihoodsNameArray = [String]()
    var likelihoodsAddressArray = [String]()

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
        
        selectView.transform = CGAffineTransform(translationX: 0, y: -selectView.frame.height)
        tableView.transform = CGAffineTransform(translationX: 0, y: tableView.frame.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser == nil {
            
            performSegue(withIdentifier: "toLogin", sender: nil)
            
        }
    }
    
    func createBikeMarkers(){
    
        let xCords = [41.993013, 41.986727, 41.994506, 41.987248]
        let yCords = [-87.660381, -87.663229, -87.665317, -87.662155]
        
        for (x, y) in zip(xCords, yCords){
        
            let position = CLLocationCoordinate2D(latitude: x, longitude: y)
            _ = BikeMarker(position: position, mapView: mapView)
            
        }
    
    }
    
    func placeAutocomplete(textField: UITextField) {
        
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        
        placeIDArray.removeAll()
        
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        placesClient.autocompleteQuery(textField.text!, bounds: bounds, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                for result in results {
                    
                    self.placeIDArray.append(result.placeID!)

                }
                
                if results.count == self.placeIDArray.count{
                    
                   self.placeIDArray = removeDuplicates(source: self.placeIDArray)
                
                    self.getPlaceName(placeIDArray: self.placeIDArray)
                
                }
            }
        })
        
    }
    
    func getPlaceName(placeIDArray: [String]){
        
        self.placeNameArray.removeAll()
        self.placeAddressArray.removeAll()
        self.placeCoordinatesArray.removeAll()
        
        for placeID in placeIDArray{
            
            placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
                
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                
                guard let place = place else {
                    print("No place details for \(placeID)")
                    return
                }
                
                let nameAddressArray = [place.name, place.formattedAddress!]
                
                self.placesDictionary[placeID] = nameAddressArray            
                self.placeNameArray.append(place.name)
                self.placeAddressArray.append(place.formattedAddress!)
                self.placeCoordinatesArray.append(place.coordinate)
               
            })
        }
    }
    
    func getLikelihoodPlaces(){
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelihoodsNameArray.append(place.name)
                    self.likelihoodsAddressArray.append(place.formattedAddress!)
                    
                }
                
                DispatchQueue.main.async {
                    
                   self.tableView.reloadData()
                    
                }
                
            }
        })
    }
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=AIzaSyCsLVTDsl-0ij-7pfF7VKDLgAebaYDQpu0")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                //self.activityIndicator.stopAnimating()
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        print(json["routes"])
                        guard let routes = json["routes"] as? NSArray else {
                            DispatchQueue.main.async {
                                //self.activityIndicator.stopAnimating()
                            }
                            return
                        }
                        
                        if (routes.count > 0) {
                            let overview_polyline = routes[0] as? NSDictionary
                            let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                            
                            let points = dictPolyline?.object(forKey: "points") as? String
                            
                            self.showPath(polyStr: points!)
                            
                            DispatchQueue.main.async {
                                //self.activityIndicator.stopAnimating()
                                
                                let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(170, 30, 30, 30))
                                self.mapView!.moveCamera(update)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                //self.activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                    DispatchQueue.main.async {
                        //self.activityIndicator.stopAnimating()
                    }
                }
            }
        })
        task.resume()
    }
    
    func showPath(polyStr: String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.strokeColor = UIColor.black
        polyline.map = mapView // Your map view
    }
    
    @IBAction func textfieldTapped(_ sender: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.5) {
            self.selectView.transform = .identity
            self.tableView.transform = .identity
        }
        
        visualEffectView.isHidden = true
        
    }

    @IBAction func signOutClicked(_ sender: Any) {
        
        do {
            
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toLogin", sender: nil)
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
            
        }
        
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
        
        mapView.camera = GMSCameraPosition(target: placeCoordinatesArray[indexPath.row], zoom: 15, bearing: 0, viewingAngle: 0)
        
        let myCurrentLocation = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
        
        let marker = GMSMarker()
        marker.position = placeCoordinatesArray[indexPath.row]
        marker.title = placeNameArray[indexPath.row]
        marker.map = mapView
        
        selectView.transform = CGAffineTransform(translationX: 0, y: -selectView.frame.height)
        tableView.transform = CGAffineTransform(translationX: 0, y: tableView.frame.height)
        
        getPolylineRoute(from: myCurrentLocation, to: placeCoordinatesArray[indexPath.row])
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        fromTextField.resignFirstResponder()
        toTextField.resignFirstResponder()
        
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
            placeAutocomplete(textField: textField)
            tableView.reloadData()
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

