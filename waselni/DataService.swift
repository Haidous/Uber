//
//  DataService.swift
//  waselni
//
//  Created by Moussa on 8/30/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import UIKit
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
    
    var mainStorageRef:StorageReference{
        
        return Storage.storage().reference()
        
    }
    
    var imageStorageRef:StorageReference{
        
        return mainStorageRef.child("profile-pictures")
        
    }
    
    func saveUser(uid: String, firstName: String, lastName:String){
        
        let profile:Dictionary<String, Any> = ["firstName": firstName, lastName:lastName]
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
}
