//
//  ProfileCell.swift
//  Flyk
//
//  Created by Edward Chapman on 7/23/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//



import UIKit
import AVFoundation


class ProfileHeaderView: UIView {
    
    let profileImageView = UIImageView()
    let usernameLabel = UILabel()
    let bioTextView = UITextView()
    let settingsImgView = UIImageView(image: UIImage(named: "settings"))
    let signInButton = UIButton(frame: .zero)
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override init(frame: CGRect){
        super.init(frame: frame)
//        getMyProfile()
        self.backgroundColor = .flykLightBlack
        let profileImageWidth: CGFloat = 100
        profileImageView.layer.cornerRadius = profileImageWidth/2;
        profileImageView.layer.masksToBounds = true;
        profileImageView.backgroundColor = UIColor.flykLoadingGrey
        
        usernameLabel.backgroundColor = .clear
        usernameLabel.textColor = .white
        usernameLabel.text = ""
        usernameLabel.font = usernameLabel.font.withSize(20)
        
        bioTextView.backgroundColor = .clear
        bioTextView.textColor = .flykDarkWhite
        bioTextView.text = ""
        bioTextView.font = UIFont.systemFont(ofSize: 16)
        bioTextView.isEditable = false
        
        
        settingsImgView.isUserInteractionEnabled = true
        settingsImgView.contentMode = .scaleAspectFit
        settingsImgView.frame = CGRect(
            x: self.frame.width - 50,
            y: 50,
            width: 30,
            height: 30
        )

        self.addSubview(settingsImgView)
        
        
        self.addSubview(profileImageView)
        self.addSubview(usernameLabel)
        self.addSubview(bioTextView)
        
        let leftInset: CGFloat = 18
        let rightInset: CGFloat = -18
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftInset).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageWidth).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50).isActive = true
        
        bioTextView.translatesAutoresizingMaskIntoConstraints = false
        bioTextView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        bioTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rightInset).isActive = true
        bioTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: leftInset).isActive = true
        bioTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: rightInset).isActive = true
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -6).isActive = true
        usernameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: leftInset).isActive = true
        usernameLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
//        usernameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 50).isActive = true
        
        
        self.addSubview(signInButton)
        signInButton.backgroundColor = .flykBlue
        signInButton.layer.cornerRadius = 13
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        signInButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        signInButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
//            signInButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        signInButton.isHidden = true
        
    }
    
    @objc func signInButtonTapped(sender: UIButton, forEvent event: UIEvent) {
        appDelegate.triggerSignInIfNoAccount(customMessgae: "Sign In")
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func fetchProfileData() {
        
        let url = URL(string: FlykConfig.mainEndpoint + "/myProfile")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            
            do {
                let myProfileData : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                // { user_id, username, profile_img_filename, profile_bio }
                if let usernameString = myProfileData["username"] as? String {
                    DispatchQueue.main.async {
                        self.usernameLabel.text = usernameString
                    }
                }
                
                if let profile_bio = myProfileData["profile_bio"] as? String {
                    DispatchQueue.main.async {
                        self.bioTextView.text = profile_bio
                    }
                }

                if let profile_img_filename = myProfileData["profile_img_filename"] as? String {
                    //TODO: this
                    let pImgURL = URL(string: FlykConfig.mainEndpoint+"/profile/photo/"+profile_img_filename)!
                    print(pImgURL)
                    URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
                        DispatchQueue.main.async {
                            self.profileImageView.image = UIImage(data: data!)
                        }
                    }).resume()
                }
                
//                print(myProfileData)
//
//                self.loadProfileImage(profileImgString: myProfileData["profile_photos"] as? String ?? "default.png")
                
//                DispatchQueue.main.async {
//                    self.usernameTextView.text = myProfileData["username"] as? String
//                    self.bioTextView.text = myProfileData["bio"] as? String
//                }
                
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            
            }.resume()
    }
    
//    func loadProfileImage(profileImgString: String){
//        let pImgURL = URL(string: FlykConfig.mainEndpoint+"/profilePhotos/"+profileImgString)!
//        print(pImgURL)
//        URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
//            DispatchQueue.main.async {
//                print(data)
//                self.profileImage.image = UIImage(data: data!)
//            }
//        }).resume()
//
//    }
//
}


