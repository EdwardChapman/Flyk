//
//  CommentsTableViewCell.swift
//  Flyk
//
//  Created by Edward Chapman on 8/17/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//


import UIKit

class CommentsTableViewCell: UITableViewCell {
    let contextProfileImg = UIImageView()
    let commentLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let leftInset: CGFloat = 18
        let rightInset: CGFloat = -18
        
        let cellSpacing: CGFloat = 12
        self.addSubview(contextProfileImg)
        self.addSubview(commentLabel)
        
        let contextProfileImgWidth: CGFloat = 45
        contextProfileImg.layer.cornerRadius = contextProfileImgWidth/2
        contextProfileImg.clipsToBounds = true
        
        commentLabel.textColor = .white
        
        commentLabel.lineBreakMode = .byWordWrapping
        commentLabel.numberOfLines = 0
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
        
        
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.leadingAnchor.constraint(equalTo: contextProfileImg.trailingAnchor, constant: 20).isActive = true
        commentLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rightInset).isActive = true
        //        notificationLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        commentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        commentLabel.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: cellSpacing).isActive = true
        commentLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: cellSpacing).isActive = true
        
        
        self.backgroundColor = .flykDarkGrey
    }
    
    override func prepareForReuse() {
        self.contextProfileImg.image = nil
        self.commentLabel.text = ""
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

