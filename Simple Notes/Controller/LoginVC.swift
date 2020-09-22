//
//  LoginVC.swift
//  Very Simple Notes
//
//  Created by Савелий Сакун on 07.07.2020.
//  Copyright © 2020 Savely Sakun. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designSetup()
    }
    
    // MARK: - IBActions
    @IBAction func tapLogin(_ sender: Any) {
        login()
    }
    
    // MARK: - Helpers
    func designSetup() {
        emailView.layer.cornerRadius = 10
        passwordView.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 10
    }
    
    func login() {
        
        if let email = emailField.text, let password = passwordField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                
                if let errorText = error {
                    // Dealing with errors.
                    self.errorWithLoginAlert(error: errorText)
                    
                } else {
                    // Succes login.
                    self.performSegue(withIdentifier: K.segues.loginComplete, sender: self)
                }
            }
        }
    }
    
    func errorWithLoginAlert(error: Error?) {
        
        let alert = UIAlertController(title: "Login Error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
