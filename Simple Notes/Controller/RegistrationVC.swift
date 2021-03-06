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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designSetup()
    }
    
    // MARK: - IBAction
    @IBAction func tapOnRegisterButton(_ sender: UIButton) {
        handleRegisterNewUser()
    }
    
    // MARK: - Helpers
    func designSetup() {
        navigationItem.title = "Registration"
        emailView.layer.cornerRadius = 10
        passwordView.layer.cornerRadius = 10
        registerButton.layer.cornerRadius = 10
    }
    
    func handleRegisterNewUser() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        
        FirebaseService.shared.registerNewUser(email: email, password: password) { error, result in
            if let error = error {
                self.showRegistrationErrorAlert(error: error)
            } else {
                self.performSegue(withIdentifier: K.segues.registrationComplete, sender: self)
            }
        }
    }
    
    func showRegistrationErrorAlert(error: Error?) {
        let alert = UIAlertController(title: "Registration Error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
