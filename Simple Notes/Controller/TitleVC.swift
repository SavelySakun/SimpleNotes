//
//  TitleVC.swift
//  Very Simple Notes
//
//  Created by Савелий Сакун on 07.07.2020.
//  Copyright © 2020 Savely Sakun. All rights reserved.
//

import UIKit

class TitleVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        designSetup()
    }
    
    // MARK: - Helpers
    func designSetup() {
        registerButton.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 10
    }
}
