//
//  CommentsTableViewCell.swift
//  Flyk
//
//  Created by Edward Chapman on 8/17/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//


import UIKit

class CommentsTableViewCell: UITableViewCell {
    var currentCommentData: NSMutableDictionary?
    
    let profileImageView = UIImageView()
    let commentLabel = UILabel()
    let heartImgView: UIImageView = {
        let img = UIImageView(image: UIImage(named: "newHeartV5"), highlightedImage: UIImage(named: "newHeartV5Red"))
        img.contentMode = .scaleAspectFit
        img.isUserInteractionEnabled = true
        return img
    }()
    
    let likesCounterLabel: UILabel = {
        let label = UILabel()
//        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = UIColor.flykDarkWhite
        label.textAlignment = .center
        return label
    }()
    
    var isCommentLiked: Bool = false {
        didSet{
            DispatchQueue.main.async {
                self.heartImgView.isHighlighted = self.isCommentLiked
            }
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let leftInset: CGFloat = 12
        let rightInset: CGFloat = -12
        
        let cellSpacing: CGFloat = 12
        self.addSubview(profileImageView)
        self.addSubview(commentLabel)
        self.addSubview(heartImgView)
        self.addSubview(likesCounterLabel)
        
        let contextProfileImgWidth: CGFloat = 34
        profileImageView.layer.cornerRadius = contextProfileImgWidth/2
        profileImageView.clipsToBounds = true
        
        self.heartImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCommentLikeTap(tapGesture:))))
        
        commentLabel.textColor = .white
        
        commentLabel.lineBreakMode = .byWordWrapping
        commentLabel.numberOfLines = 50
        commentLabel.font = UIFont.systemFont(ofSize: 14)
        //        notificationLabel.textAlignment = .center
        self.contentView.frame.size = CGSize(width: self.contentView.frame.width, height: 70)
        
        profileImageView.backgroundColor = .flykLoadingGrey
        profileImageView.isUserInteractionEnabled = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftInset).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: contextProfileImgWidth).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: cellSpacing).isActive = true
        profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: cellSpacing).isActive = true
        
        
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: leftInset).isActive = true
        commentLabel.trailingAnchor.constraint(equalTo: heartImgView.leadingAnchor, constant: rightInset).isActive = true
        //        notificationLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        commentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        commentLabel.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: cellSpacing).isActive = true
        commentLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: cellSpacing).isActive = true
        
        
        heartImgView.translatesAutoresizingMaskIntoConstraints = false
        heartImgView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: rightInset*2).isActive = true
        heartImgView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        heartImgView.widthAnchor.constraint(equalToConstant: 17).isActive = true
        heartImgView.heightAnchor.constraint(equalTo: heartImgView.widthAnchor).isActive = true
        
        likesCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        likesCounterLabel.leadingAnchor.constraint(equalTo: heartImgView.leadingAnchor, constant: -8).isActive = true
        likesCounterLabel.trailingAnchor.constraint(equalTo: heartImgView.trailingAnchor, constant: 8).isActive = true
        likesCounterLabel.topAnchor.constraint(equalTo: heartImgView.bottomAnchor, constant: 3).isActive = true
//        likesCounterLabel.heightAnchor.constraint(equalTo: likesCounterLabel.widthAnchor, multiplier: 0.7).isActive = true
        
        
        

        
        
        
        self.backgroundColor = .flykDarkGrey
    }
    
    override func prepareForReuse() {
        self.profileImageView.image = nil
        self.commentLabel.text = ""
        self.profileImageView.gestureRecognizers?.removeAll()
        self.heartImgView.isHighlighted = false
        self.currentCommentData = nil
        self.isCommentLiked = false
    }
    
    func setupNewComment(commentData: NSMutableDictionary) {
        self.currentCommentData = commentData
        if let comment_text = commentData["comment_text"] as? String {
            self.commentLabel.text = comment_text
            if let username = commentData["username"] as? String {
                self.commentLabel.text = username + " " + self.commentLabel.text!
                if let mut = self.commentLabel.attributedText?.mutableCopy() as? NSMutableAttributedString{
                    mut.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)], range: NSRange(location: 0, length: username.count))
                    self.commentLabel.attributedText = mut
                }
                
            }
        }
        
        if let pImgFilename = commentData["profile_img_filename"] as? String {
            let pImgURL = URL(string: FlykConfig.mainEndpoint+"/profile/photo/"+pImgFilename)!
            URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
                if let d = data {
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(data: d)
                    }
                }
            }).resume()
        } else {
            self.profileImageView.image = FlykConfig.defaultProfileImage
        }
        
        if let is_liked_by_user = commentData["is_liked_by_user"] as? Bool {
            if is_liked_by_user {
                self.isCommentLiked = true
            }else {
                self.isCommentLiked = false
            }
        }
        
        if let likes_count = commentData["likes_count"] as? Int {
//            self.likesCounterLabel = String(likes_count)
            
            var countText: String?
            if likes_count >= 1000 {
                let thousands = Float(likes_count)/1000
                countText = String(format: "%.1fK", thousands)
                if thousands >= 1000 {
                    let millions = thousands / 1000
                    countText = String(format: "%.1fM", millions)
                }
            }else {
                countText = String(likes_count)
            }
            self.likesCounterLabel.text = countText
        }
        
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    
    @objc func handleCommentLikeTap(tapGesture: UITapGestureRecognizer) {
        print("HANDLE COMMENT LIKE TAP")

        if let imgView = tapGesture.view as? UIImageView {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            
            if !isCommentLiked /* LIKE VIDEO */ {
                self.isCommentLiked = true
                
                let videoListURL = URL(string: FlykConfig.mainEndpoint+"/video/comments/like")!
                
                var request = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let parameters: NSDictionary = ["commentId": self.currentCommentData?["comment_id"]]
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch let error {
                    print(error.localizedDescription)
                    return;
                }
                
                
                request.httpMethod = "POST"
                URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    if error != nil {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                        self.isCommentLiked = false
                        return
                    }
                    guard let response = response as? HTTPURLResponse else {
                        print("not httpurlresponse...!")
                        return;
                    }
                    
                    if(response.statusCode == 200) {
                        DispatchQueue.main.async {
                            
                            self.currentCommentData?["is_liked_by_user"]? = true
                            // NEED TO PASS THIS LIKE UP TO THE PARENT
                            if var curCount = self.currentCommentData?["likes_count"] as? Int {
                                curCount += 1
                                self.currentCommentData?["likes_count"] = curCount
                                self.likesCounterLabel.text = String(curCount)
                                
                            }
                        }
                        //Worked....
                    }else{
                        print("Response not 200", response)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                        self.isCommentLiked = false
                    }
                    
                    }.resume()
                
                
            }else{ // UNLIKE VIDEO
                self.isCommentLiked = false
                
                let videoListURL = URL(string: FlykConfig.mainEndpoint+"/video/comments/unlike")!
                
                var request = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let parameters: NSDictionary = ["commentId": self.currentCommentData?["comment_id"]]
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch let error {
                    print(error.localizedDescription)
                    return;
                }
                
                
                request.httpMethod = "POST"
                URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    if error != nil {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                        self.isCommentLiked = true
                        return
                    }
                    guard let response = response as? HTTPURLResponse else {
                        print("not httpurlresponse...!")
                        return;
                    }
                    
                    if(response.statusCode == 200) {
                        //Worked....
                        DispatchQueue.main.async {
                            //                                self.currentVideoData?.setValue(false, forKeyPath: "is_liked_by_user")
                            // NEED TO PASS THIS DISLIKE UP TO THE PARENT
                            self.currentCommentData?["is_liked_by_user"]? = false
                            if var curCount = self.currentCommentData?["likes_count"] as? Int {
                                curCount -= 1
                                self.currentCommentData?["likes_count"] = curCount
                                self.likesCounterLabel.text = String(curCount)
                                
                            }
                        }
                    }else{
                        print("Response not 200", response)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                        self.isCommentLiked = true
                    }
                    
                    }.resume()
                
                
                
                
                
                
            }
            
            
            
        }
        
    }
}

