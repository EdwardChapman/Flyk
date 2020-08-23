//
//  ProfileCell.swift
//  Flyk
//
//  Created by Edward Chapman on 7/23/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//



import UIKit
import AVFoundation


enum profileDisplayType {
    case signedIn, notSignedIn, following, notFollowing
}


class ProfileHeaderView: UIView {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var oneTwoTwoGrey = UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1)
    
    let profileImageView = UIImageView(image: FlykConfig.defaultProfileImage)
    let usernameLabel = UILabel()
    let bioTextView = UILabel()
    let settingsImgView = UIImageView(image: UIImage(named: "settings"))
    
    
    
    
    
    var currentProfileData: NSMutableDictionary? {
        didSet {
            guard let currentProfileData = self.currentProfileData else { return }
            
            // { user_id, username, profile_img_filename, profile_bio }
            if let usernameString = currentProfileData["username"] as? String {
                DispatchQueue.main.async {
                    self.usernameLabel.text = usernameString
                }
            }
            
            if let profile_bio = currentProfileData["profile_bio"] as? String {
                DispatchQueue.main.async {
                    self.bioTextView.text = profile_bio
                }
            }
            
            if let profile_img_filename = currentProfileData["profile_img_filename"] as? String {
                //TODO: this
                let pImgURL = URL(string: FlykConfig.mainEndpoint+"/profile/photo/"+profile_img_filename)!
                print(pImgURL)
                URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
                    if let d = data {
                        DispatchQueue.main.async {
                            self.profileImageView.image = UIImage(data: d)
                        }
                    }
                }).resume()
            } else {
                DispatchQueue.main.async {
                    self.profileImageView.image = FlykConfig.defaultProfileImage
                }
            }
        }
    }
    
    var profileDisplayStatus : profileDisplayType = .notSignedIn {
        didSet{
            if self.profileDisplayStatus == .notSignedIn {
                self.signInButton.isHidden = false
                self.followingButton.isHidden = true
                self.followButton.isHidden = true
                self.editProfileButton.isHidden = true
            } else if self.profileDisplayStatus == .signedIn {
                self.signInButton.isHidden = true
                self.followingButton.isHidden = true
                self.followButton.isHidden = true
                self.editProfileButton.isHidden = false
            } else if self.profileDisplayStatus == .following {
                self.signInButton.isHidden = true
                self.followingButton.isHidden = false
                self.followButton.isHidden = true
                self.editProfileButton.isHidden = true
            } else if self.profileDisplayStatus == .notFollowing {
                self.signInButton.isHidden = true
                self.followingButton.isHidden = true
                self.followButton.isHidden = false
                self.editProfileButton.isHidden = true
            }
        }
    }
    
    
    
    
    lazy var signInButton: UIButton = {
        let signInButton = UIButton(frame: .zero)
        self.addSubview(signInButton)
        signInButton.backgroundColor = .flykBlue
        signInButton.layer.cornerRadius = 8
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 125).isActive = true
        signInButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        signInButton.isHidden = true
        return signInButton
    }()
    lazy var editProfileButton: UIButton = {
        let editProfileButton = UIButton()
        self.addSubview(editProfileButton)
        editProfileButton.backgroundColor = .clear
        editProfileButton.layer.borderColor = oneTwoTwoGrey.cgColor
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.cornerRadius = 8
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        editProfileButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8).isActive = true
        editProfileButton.widthAnchor.constraint(equalToConstant: 125).isActive = true
        editProfileButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        editProfileButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        editProfileButton.setTitle("Edit Profile", for: .normal)
        editProfileButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        editProfileButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        editProfileButton.setTitleColor(oneTwoTwoGrey, for: .normal)
        editProfileButton.isHidden = true
        return editProfileButton
        
    }()
    
    lazy var followButton: UIButton = {
        let followButton = UIButton()
        self.addSubview(followButton)
        followButton.backgroundColor = .flykBlue
        followButton.layer.cornerRadius = 8
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8).isActive = true
        followButton.widthAnchor.constraint(equalToConstant: 125).isActive = true
        followButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        followButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        followButton.setTitle("Follow", for: .normal)
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        followButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        followButton.isHidden = true
        return followButton
    }()
    lazy var followingButton: UIButton = {
        let followingButton = UIButton()
        self.addSubview(followingButton)
        followingButton.backgroundColor = .clear
        followingButton.layer.borderColor = oneTwoTwoGrey.cgColor
        followingButton.layer.borderWidth = 1
        followingButton.layer.cornerRadius = 8
        followingButton.translatesAutoresizingMaskIntoConstraints = false
        followingButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8).isActive = true
        followingButton.widthAnchor.constraint(equalToConstant: 125).isActive = true
        followingButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        followingButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        followingButton.setTitle("Following", for: .normal)
        followingButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        followingButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        followingButton.setTitleColor(oneTwoTwoGrey, for: .normal)
        followingButton.isHidden = true
        followingButton.titleEdgeInsets.right = 20
        let origImage = UIImage(named: "blueCheckAlone")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        
        let checkImgView = UIImageView(image: tintedImage)
        checkImgView.tintColor = oneTwoTwoGrey
        followingButton.addSubview(checkImgView)
        checkImgView.translatesAutoresizingMaskIntoConstraints = false
        checkImgView.leadingAnchor.constraint(equalTo: followingButton.titleLabel!.trailingAnchor, constant: 5).isActive = true
        checkImgView.centerYAnchor.constraint(equalTo: followingButton.centerYAnchor).isActive = true
        checkImgView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        checkImgView.heightAnchor.constraint(equalTo: checkImgView.widthAnchor).isActive = true
        checkImgView.contentMode = .scaleAspectFit
        return followingButton
    }()
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
//        getMyProfile()
        self.backgroundColor = .flykLightBlack
        let profileImageWidth: CGFloat = 100
        profileImageView.layer.cornerRadius = profileImageWidth/2;
        profileImageView.layer.masksToBounds = true;
        profileImageView.backgroundColor = UIColor.flykLoadingGrey
        profileImageView.isUserInteractionEnabled = true
        profileImageView.contentMode = .scaleToFill
//        profileImageView.image = FlykConfig.defaultProfileImage
        
        let leftInset: CGFloat = 17
        let rightInset: CGFloat = -17
        
        
        usernameLabel.backgroundColor = .clear
        usernameLabel.textColor = .white
        usernameLabel.text = ""
        usernameLabel.font = usernameLabel.font.withSize(17)
        
        bioTextView.backgroundColor = .clear
        bioTextView.textColor = .flykDarkWhite
        bioTextView.text = ""
        bioTextView.font = UIFont.systemFont(ofSize: 15)
        bioTextView.numberOfLines = 50
//        bioTextView.isEditable = false
        
        
        
        settingsImgView.isUserInteractionEnabled = true
        settingsImgView.contentMode = .scaleAspectFit
        
        
        self.addSubview(settingsImgView)
        self.addSubview(profileImageView)
        self.addSubview(usernameLabel)
        self.addSubview(bioTextView)

        
        settingsImgView.translatesAutoresizingMaskIntoConstraints = false
        settingsImgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rightInset).isActive = true
        settingsImgView.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        settingsImgView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        settingsImgView.heightAnchor.constraint(equalTo: settingsImgView.widthAnchor).isActive = true




        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftInset).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageWidth).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50).isActive = true
        
        

        
        

        
        
        
        
        


        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: 0).isActive = true
        usernameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rightInset).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12).isActive = true

        
        bioTextView.translatesAutoresizingMaskIntoConstraints = false
        bioTextView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        bioTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rightInset).isActive = true
        bioTextView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 17).isActive = true

    
        self.bottomAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: leftInset).isActive = true
        

    }
    
    @objc func signInButtonTapped(sender: UIButton, forEvent event: UIEvent) {
        if appDelegate.triggerSignInIfNoAccount(customMessgae: "Sign In") {
            print("RELOAD VIEW HERE")
        }
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


