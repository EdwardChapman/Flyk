//
//  PostsCell.swift
//  Flyk
//
//  Created by Edward Chapman on 7/26/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation


class PostsCell: UICollectionViewCell {
    
    let profileImage = UIImageView()
    let usernameLabel = UILabel()
    let bioTextView = UITextView()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        //        getMyProfile()
        
        let profileImageWidth: CGFloat = 100
        profileImage.layer.cornerRadius = profileImageWidth/2;
        profileImage.layer.masksToBounds = true;
        profileImage.backgroundColor = UIColor.flykLoadingGrey
        
        usernameLabel.backgroundColor = .clear
        usernameLabel.textColor = .white
        usernameLabel.text = "eddiewardie"
        usernameLabel.font = usernameLabel.font.withSize(20)
        
        bioTextView.backgroundColor = .clear
        bioTextView.textColor = .flykDarkWhite
        bioTextView.text = "Hello this is my profile\nRoar"
        bioTextView.font = bioTextView.font!.withSize(16)
        
        let settingsImgView = UIImageView(image: UIImage(named: "settings"))
        settingsImgView.contentMode = .scaleAspectFit
        settingsImgView.frame = CGRect(
            x: self.frame.width - 50,
            y: 50,
            width: 30,
            height: 30
        )
        self.addSubview(settingsImgView)
        
        
        self.addSubview(profileImage)
        self.addSubview(usernameLabel)
        self.addSubview(bioTextView)
        
        let leftInset: CGFloat = 18
        let rightInset: CGFloat = -18
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftInset).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: profileImageWidth).isActive = true
        profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor).isActive = true
        profileImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 50).isActive = true
        
        bioTextView.translatesAutoresizingMaskIntoConstraints = false
        bioTextView.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor).isActive = true
        bioTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rightInset).isActive = true
        bioTextView.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: leftInset).isActive = true
        bioTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: rightInset).isActive = true
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: -6).isActive = true
        usernameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: leftInset).isActive = true
        usernameLabel.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor).isActive = true
        //        usernameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 50).isActive = true
        
    }
    
    @objc func handlePauseTapGesture(tapGesture: UITapGestureRecognizer){
        
    }
    
    func addOverlay(){
        
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



