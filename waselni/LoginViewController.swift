//
//  ViewController.swift
//  waselni
//
//  Created by Moussa on 8/30/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: FancyTextField!
    @IBOutlet weak var passwordTextField: FancyTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    
    func checkfields() -> Bool{
        
        if emailTextField.text == "" || passwordTextField.text == ""{
            
            let alert = UIAlertController(title: "All Fields Are Required.", message: "Please fill all the fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay!", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
            return false
            
        }else{
            
            return true
            
        }
        
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        if checkfields(){
        
            AuthService.instance.signin(email: self.emailTextField.text!, password: self.passwordTextField.text!, onComplete: { (error, data) in
                
                if error != nil{
                
                    let alert = UIAlertController(title: "Error Authenticating", message: error!, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay!", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)

                
                }else{
                
                    self.performSegue(withIdentifier: "toMainView1", sender: self)
                    
                }
                
            })
        
        }
        
    }
    
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }
    
}

