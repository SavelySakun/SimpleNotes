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
    @IBAction func tapOnLoginButton(_ sender: Any) {
        handleUserLogin()
    }
    
    // MARK: - Helpers
    func designSetup() {
        navigationItem.title = "Login"
        emailView.layer.cornerRadius = 10
        passwordView.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 10
    }
    
    func handleUserLogin() {
        if let email = emailField.text, let password = passwordField.text {
            
            FirebaseService.shared.loginExistingUser(email: email, password: password) { error, result in
                if let errorText = error {
                    self.showErrorLoginAlert(error: errorText)
                } else {
                    self.performSegue(withIdentifier: K.segues.loginComplete, sender: self)
                }
            }
        }
    }
    
    func showErrorLoginAlert(error: Error?) {
        
        let alert = UIAlertController(title: "Login Error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
