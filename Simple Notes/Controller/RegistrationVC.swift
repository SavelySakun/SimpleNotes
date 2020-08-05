//
//  RegistrationVC.swift
//  Very Simple Notes
//
//  Created by Савелий Сакун on 07.07.2020.
//  Copyright © 2020 Savely Sakun. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class RegistrationVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // Firestore database.
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designSetup()
    }

    // MARK: - IBAction
    @IBAction func tapRegister(_ sender: UIButton) {
        
        registration()
    }
    
    // MARK: - Helpers
    func designSetup() {
        emailView.layer.cornerRadius = 10
        passwordView.layer.cornerRadius = 10
        registerButton.layer.cornerRadius = 10
    }
    
    func registration() {
        
        if let email = emailField.text, let password = passwordField.text {
           
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
              
                if let errorText = error {
                    
                    // Dealing with errors.
                    self.errorWithRegistrationAlert(error: errorText)
                    
                } else {
                    
                    // Succes registration.
                    self.performSegue(withIdentifier: K.segues.registrationComplete, sender: self)
                }
            }
        }
    }
    
    func errorWithRegistrationAlert(error: Error?) {
        
        let alert = UIAlertController(title: "Registration Error", message: "\(error!.localizedDescription)", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
