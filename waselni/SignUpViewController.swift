//
//  SignUpViewController.swift
//  waselni
//
//  Created by Moussa on 8/30/17.
//  Copyright © 2017 Moussa. All rights reserved.
//

//TODO: FIX SCROLL VIEW BUG, WORKS EVERY OTHER TIME

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: FancyTextField!
    @IBOutlet weak var lastNameTextField: FancyTextField!
    @IBOutlet weak var emailTextField: FancyTextField!
    @IBOutlet weak var passwordTextField: FancyTextField!
    @IBOutlet weak var phoneTextField: FancyTextField!
    
    @IBOutlet var scrollView: UIScrollView!
    
    var activeField: UITextField?
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.phoneTextField.delegate = self
        
        imagePicker.delegate = self
        
        registerForKeyboardNotifications()
        
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        deregisterFromKeyboardNotifications()
        
    }
    
    func checkFields() -> Bool{
        
        if firstNameTextField.text == "" || lastNameTextField.text == "" ||  emailTextField.text == "" || passwordTextField.text == "" || phoneTextField.text == ""{
            
            let alert = UIAlertController(title: "All Fields Are Required.", message: "Please fill all the fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay!", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
            return false
            
        }else{
            
            return true
            
        }
        
        
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
        
    }

    @IBAction func editProfilePictureTapped(_ sender: UITapGestureRecognizer) {
        
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func createAccountClicked(_ sender: UIButton) {
        
        if checkFields(){
        
            AuthService.instance.createUser(email: emailTextField.text!, password: passwordTextField.text!, onComplete: { (error, data) in
                
                let user = data as! User
                let userID = user.uid
                
                DataService.instance.saveUser(uid: userID, firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!)
                
                DataService.instance.uploadPicture(imageView: self.profilePictureImageView, uid: userID)
                
                self.performSegue(withIdentifier: "toMainView2", sender: self)
                
            })
        
        }
        
        
    }
    
}

extension SignUpViewController:UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePictureImageView.contentMode = .scaleAspectFit
            profilePictureImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    

    func registerForKeyboardNotifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func deregisterFromKeyboardNotifications(){
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)

            }
        }
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
}
