//
//  MapServices.swift
//  waselni
//
//  Created by Moussa on 9/3/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class MapService{

    private static let _instance = MapService()
    
    var placesClient = GMSPlacesClient()
    
    static var instance:MapService{
        
        return _instance
        
    }
    
    func createBikeMarkers(mapView: GMSMapView){
        
        DataService.instance.getActiveDriverCoords { (error, data) in
            
            mapView.clear()
            
            let bikeCoordinates = data as! CLLocationCoordinate2D
            
            let position = bikeCoordinates
            _ = BikeMarker(position: position, mapView: mapView)
            
        }
        
    }
    
    func placeAutocomplete(mapView: GMSMapView, textField:UITextField, onComplete:Completion?){
        
        var placeIDArray = [String]()
        
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        placesClient.autocompleteQuery(textField.text!, bounds: bounds, filter: filter, callback: {(results, error) -> Void in
            
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            
            if let results = results {
                
                var dupPlaceIDArray = [String]()
                
                for result in results {
                    
                    dupPlaceIDArray.append(result.placeID!)
                    
                }
                
                if results.count == dupPlaceIDArray.count{
                    
                    placeIDArray = removeDuplicates(source: dupPlaceIDArray)
                    
                    onComplete!(nil, placeIDArray )
                    
                }
            }
        })
        
    }
    
    func getPlaceInformation(placeIDArray:[String], onComplete:Completion?){
        
        var placeNameArray = [String]()
        var placeAddressArray = [String]()
        var placeCoordinatesArray = [CLLocationCoordinate2D]()
    
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
                
                placeNameArray.append(place.name)
                placeAddressArray.append(place.formattedAddress!)
                placeCoordinatesArray.append(place.coordinate)
                
                let placeInformationArray = [placeNameArray, placeAddressArray, placeCoordinatesArray] as [Any]
                
                onComplete!(nil, placeInformationArray)
                
            })
        }

    }
    
    func getLikelihoodPlaces(onComplete: Completion?){
        
        var likelihoodsNameArray = [String]()
        var likelihoodsAddressArray = [String]()
        var likelihoodsCoordinatesArray = [CLLocationCoordinate2D]()
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList.likelihoods {
                    
                    let place = likelihood.place
                    
                    likelihoodsNameArray.append(place.name)
                    likelihoodsAddressArray.append(place.formattedAddress!)
                    likelihoodsCoordinatesArray.append(place.coordinate)
                    
                    let likelihoodsInformation = [likelihoodsNameArray, likelihoodsAddressArray, likelihoodsCoordinatesArray] as [Any]
                    
                    onComplete!(nil, likelihoodsInformation)
                    
                }
            }
        })
    }
    
    func getDirections(mapView: GMSMapView, origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, onComplete: Completion?) {
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=AIzaSyCsLVTDsl-0ij-7pfF7VKDLgAebaYDQpu0")!
        
        var polyline:GMSPolyline?
        
        Alamofire.request(url).responseJSON { response in
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes {
                
                
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                polyline = GMSPolyline.init(path: path)
                
                polyline?.map = nil
                
                polyline!.strokeColor = UIColor.darkGray
                polyline!.strokeWidth = 3.0
                polyline!.map = mapView
                
            }
        }
    }
    
    func estimateDistanceAndTime(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, onComplete: Completion?){
    
        let url = URL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=\(origin.latitude),\(origin.longitude)&destinations=\(destination.latitude),\(destination.longitude)&key=AIzaSyDZ-i_-GkFm8TeybCMjXWoNvK6ObyiaHOY")!
    
        Alamofire.request(url).responseJSON { response in
            
            let json = JSON(data: response.data!)
            let rows = json["rows"].array
            let generalElements = rows![0].dictionaryValue
            let elements = generalElements["elements"]
            let element = elements![0]
            let distanceDict = element["distance"]
            let distanceText = distanceDict["text"]
            let timeDict = element["duration"]
            let timeText = timeDict["text"]
            
            let estimation = [distanceText, timeText] as [Any]
            
            onComplete!(nil, estimation)
    
        }
    }

}
