//
//  DataService.swift
//  waselni
//
//  Created by Moussa on 8/30/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class DataService{
    
    private static let _instance = DataService()
    
    static var instance:DataService{
        
        return _instance
        
    }
    
    var mainRef:DatabaseReference{
        
        return Database.database().reference()
        
    }
    
    var usersRef:DatabaseReference{
        
        return mainRef.child("users")
        
    }
    
    var activeDriversRef:DatabaseReference{
    
        return mainRef.child("activeDrivers")
    
    }
    
    var mainStorageRef:StorageReference{
        
        return Storage.storage().reference()
        
    }
    
    var imageStorageRef:StorageReference{
        
        return mainStorageRef.child("profile-pictures")
        
    }
    
    func saveUser(uid: String, firstName: String, lastName:String){
        
        let profile:Dictionary<String, Any> = ["firstName": firstName, "lastName":lastName]
        mainRef.child("users").child(uid).child("profile").setValue(profile)
        
    }
    
    func uploadPicture(imageView: UIImageView, uid: String){
        
        if let image = imageView.image{
            
            let data = UIImagePNGRepresentation(image)!
            
            let randomID = UUID().uuidString
            
            imageStorageRef.child(randomID).putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    
                    return
                }
                
                let downloadURL = metadata.downloadURL()?.absoluteString
                self.mainRef.child("users").child(uid).child("profile").child("profilePicture").setValue(downloadURL)
                
            }
            
        }
        
    }
    
    func getUsersID(onComplete: Completion?){
    
        usersRef.observe(.value, with: { (snapshot) in
            
            let firstDict = snapshot.value! as? [String: Any]
            let idArray = Array(firstDict!.keys)
            //let usersArray = Array(firstDict!.values)
            
            onComplete!(nil, idArray)
            
        })
        
    }
    
    func getActiveDriversID(onComplete: Completion?){
    
        activeDriversRef.observe(.value, with: { (snapshot) in
            
            let firstDict = snapshot.value! as? [String: Any]
            let idArray = Array(firstDict!.keys)
            
            onComplete!(nil, idArray)
            
        })
    
    }
    
    func getActiveDriverCoords(onComplete: Completion?){
    
        getActiveDriversID(onComplete: {(error, data) in
        
            let idArray = data as! [String]
            
            for id in idArray{
            
                let coordinatesRef = self.usersRef.child(id).child("currentLocation")
                
                coordinatesRef.observe(.value, with: { (snapshot) in
                    
                    let coordsDict = snapshot.value as! [String:Double]
                
                    let latitude = coordsDict["latitude"]
                    let longitude = coordsDict["longitude"]
                        
                    let bikeCoordinates = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                    
                    onComplete!(nil, bikeCoordinates)
                    
                    
                })
            
            }
            
        })
    }
    
    func uploadCDDestinationCoords(latitude: Double, longitude: Double){
    
        getActiveDriversID { (error, data) in
            
            let idArray = data as! [String]
            
            for id in idArray{
            
                let destinationLocation = ["latitude": latitude, "longitude": longitude]
                self.usersRef.child(id).child("destination").setValue(destinationLocation)

                
            }
            
        }
    
    }
    
    func uploadCUCurrentLocationCoords(latitude: Double, longitude: Double){
    
        let currentUserID = Auth.auth().currentUser?.uid
        
        let currentLocation = ["latitude": latitude, "longitude": longitude]
        usersRef.child(currentUserID!).child("currentLocation").setValue(currentLocation)
    
    }
    
    func uploadCUDestinationCoords(latitude: Double, longitude: Double){
    
        let currentUserID = Auth.auth().currentUser?.uid
        
        let destination = ["latitude": latitude, "longitude": longitude]
        usersRef.child(currentUserID!).child("destination").setValue(destination)
        
    
    }
    
}
