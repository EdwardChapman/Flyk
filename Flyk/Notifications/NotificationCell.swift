//
//  NotificationCell.swift
//  Flyk
//
//  Created by Edward Chapman on 7/23/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class NoticationCell: UITableViewCell {
    let contextProfileImg = UIImageView()
    let notificationLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let leftInset: CGFloat = 18
        let rightInset: CGFloat = -18
        
        let cellSpacing: CGFloat = 12
        self.addSubview(contextProfileImg)
        self.addSubview(notificationLabel)
        
        let contextProfileImgWidth: CGFloat = 45
        contextProfileImg.layer.cornerRadius = contextProfileImgWidth/2
        contextProfileImg.clipsToBounds = true
        
        notificationLabel.textColor = .white
        
        notificationLabel.lineBreakMode = .byWordWrapping
        notificationLabel.numberOfLines = 0
//        notificationLabel.textAlignment = .center
        self.contentView.frame.size = CGSize(width: self.contentView.frame.width, height: 70)
        
        contextProfileImg.backgroundColor = .flykLoadingGrey
        contextProfileImg.isUserInteractionEnabled = true
        contextProfileImg.translatesAutoresizingMaskIntoConstraints = false
        contextProfileImg.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftInset).isActive = true
        contextProfileImg.widthAnchor.constraint(equalToConstant: contextProfileImgWidth).isActive = true
        contextProfileImg.heightAnchor.constraint(equalTo: contextProfileImg.widthAnchor).isActive = true
        contextProfileImg.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        contextProfileImg.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: cellSpacing).isActive = true
        contextProfileImg.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: cellSpacing).isActive = true
        
        
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.leadingAnchor.constraint(equalTo: contextProfileImg.trailingAnchor, constant: 20).isActive = true
        notificationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rightInset).isActive = true
//        notificationLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        notificationLabel.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: cellSpacing).isActive = true
        notificationLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: cellSpacing).isActive = true
        
        
        self.backgroundColor = .flykDarkGrey
    }
    
    override func prepareForReuse() {
        self.contextProfileImg.image = nil
        self.notificationLabel.text = ""
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
