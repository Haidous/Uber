//
//  AuthService.swift
//  waselni
//
//  Created by Moussa on 8/30/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias Completion = (_ errorMessage: String?, _ data: Any?) -> Void

class AuthService{
    
    private static let _instance = AuthService()
    
    static var instance:AuthService{
        
        return _instance
        
    }
    
    func signin(email: String, password: String, onComplete: Completion?){
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            
            if error != nil{
                
                    
                    self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                    

                
            }else{
                
                onComplete!(nil, user)
                
            }
            
        })
        
    }
    
    func createUser(email: String, password: String, onComplete: Completion?){
    
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil{
                
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                
            }else{
                
                if user?.uid != nil{
                    
                    Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                        
                        if error != nil{
                            
                            self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                            
                        }else{
                            
                            if let user = user{
                                
                                onComplete!(nil, user)
                                
                            }
                            
                        }
                        
                    })
                    
                }
                
            }
            
        })

    
    }
    
    func handleFirebaseError(error: NSError, onComplete: Completion?){
        
        if let errorCode = AuthErrorCode(rawValue: error.code){
            
            switch errorCode {
            case .invalidEmail:
                
                onComplete?("Invalid email address.", nil)
                break
                
            case .wrongPassword:
                
                onComplete?("Wrong password.", nil)
                break
                
            case .emailAlreadyInUse,.accountExistsWithDifferentCredential:
                
                onComplete?("Could not create account. Email already in use.", nil)
                break
                
            default:
                
                onComplete?("There was a problem. Please try again.", nil)
                break
                
            }
            
        }
        
    }
    
}
