//
//  Settings.swift
//  Flyk
//
//  Created by Edward Chapman on 8/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .flykDarkGrey
        
        let logoutButton = UIButton(type: .custom)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.backgroundColor = .red
        logoutButton.layer.cornerRadius = 45/2
        logoutButton.setTitleColor(.white, for: .normal)
        self.view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        logoutButton.addTarget(self, action: #selector(handleLogoutTap), for: .touchUpInside)
        
    }
    
    @objc func handleLogoutTap(sender: UIButton, forEvent event: UIEvent){
        //NETWORK CALL TO LOGOUT HERE
        print("LOGOUT")
    }
}
