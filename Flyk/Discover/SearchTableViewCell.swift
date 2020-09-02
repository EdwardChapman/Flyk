//
//  SearchTableViewCell.swift
//  Flyk
//
//  Created by Edward Chapman on 8/26/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

//    var currentSearchResult: NSMutableDictionary?
    let contextProfileImg = UIImageView()
    let contextMessageLabel = UILabel()
    
    func setupNewSearchResult(newSearchResult: NSMutableDictionary) {
//        self.currentSearchResult = newSearchResult
        self.contextMessageLabel.text = newSearchResult["username"] as? String

        if let profile_img_filename = newSearchResult["profile_img_filename"] as? String {
            //TODO: this
            let pImgURL = URL(string: FlykConfig.mainEndpoint+"/profile/photo/"+profile_img_filename)!
            print("FETCHING PIMG", pImgURL)
            
            URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
                if let d = data {
                    DispatchQueue.main.async {
                        self.contextProfileImg.image = UIImage(data: d)
                    }
                }
            }).resume()
        } else {
            DispatchQueue.main.async {
                self.contextProfileImg.image = FlykConfig.defaultProfileImage
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let leftInset: CGFloat = 18
        let rightInset: CGFloat = -18
        
        let cellSpacing: CGFloat = 12
        self.addSubview(contextProfileImg)
        self.addSubview(contextMessageLabel)
        
        let contextProfileImgWidth: CGFloat = 45
        contextProfileImg.layer.cornerRadius = contextProfileImgWidth/2
        contextProfileImg.clipsToBounds = true
        
        contextMessageLabel.textColor = .white
        
        contextMessageLabel.lineBreakMode = .byWordWrapping
        contextMessageLabel.numberOfLines = 0
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
        
        
        contextMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        contextMessageLabel.leadingAnchor.constraint(equalTo: contextProfileImg.trailingAnchor, constant: 20).isActive = true
        contextMessageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rightInset).isActive = true
        //        notificationLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        contextMessageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        contextMessageLabel.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: cellSpacing).isActive = true
        contextMessageLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: cellSpacing).isActive = true
        
        
        self.backgroundColor = .flykDarkGrey
    }
    
    override func prepareForReuse() {
        self.contextProfileImg.image = nil
        self.contextMessageLabel.text = ""
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
