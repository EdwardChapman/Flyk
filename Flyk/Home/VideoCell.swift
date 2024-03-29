//
//  VideoCell.swift
//  Flyk
//
//  Created by Edward Chapman on 7/15/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//




import UIKit
import AVFoundation
//class overlayReusableView: UICollectionReusableView {
// // I COULD USE THIS TO REUSE OVERLAY
//}

class VideoCell: UICollectionViewCell {
    
    
    let player = AVPlayer()
    let playerLayer = AVPlayerLayer()
    var videoDidEndObserver: NSObjectProtocol?
    
    lazy var pause: UIImageView = {
        let p = UIImageView(image: UIImage(named: "pause"))
        p.contentMode = .scaleAspectFit
        self.addSubview(p)
        p.translatesAutoresizingMaskIntoConstraints = false
        p.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        p.centerYAnchor.constraint(equalTo: profileImg.centerYAnchor).isActive = true
        p.heightAnchor.constraint(equalToConstant: 30).isActive = true
        p.widthAnchor.constraint(equalToConstant: 30).isActive = true
        p.alpha = 0.7
        p.isHidden = true
        return p
    }()
    
    lazy var moreOptions: UIView = {
        let v = UIView()
        self.addSubview(v)
        let a = UIView()
        let b = UIView()
        let c = UIView()
        
        v.addSubview(a)
        v.addSubview(b)
        v.addSubview(c)
        let dotWidth: CGFloat = 5
        
        let blackBorder = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        
        a.layer.cornerRadius = dotWidth/2
        a.backgroundColor = UIColor.flykDarkWhite
        a.alpha = 1
//        a.layer.borderColor = blackBorder
//        a.layer.borderWidth = 1
        
        
        b.layer.cornerRadius = dotWidth/2
        b.backgroundColor = UIColor.flykDarkWhite
        b.alpha = 1
//        b.layer.borderColor = blackBorder
//        b.layer.borderWidth = 1
        
        c.layer.cornerRadius = dotWidth/2
        c.backgroundColor = UIColor.flykDarkWhite
        c.alpha = 1
//        c.layer.borderColor = blackBorder
//        c.layer.borderWidth = 1
        
        a.translatesAutoresizingMaskIntoConstraints = false
        a.heightAnchor.constraint(equalToConstant: dotWidth).isActive = true
        a.widthAnchor.constraint(equalToConstant: dotWidth).isActive = true
        a.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        a.topAnchor.constraint(equalTo: v.topAnchor).isActive = true
        
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: dotWidth).isActive = true
        b.widthAnchor.constraint(equalToConstant: dotWidth).isActive = true
        b.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        b.topAnchor.constraint(equalTo: a.bottomAnchor, constant: 5).isActive = true

        c.translatesAutoresizingMaskIntoConstraints = false
        c.heightAnchor.constraint(equalToConstant: dotWidth).isActive = true
        c.widthAnchor.constraint(equalToConstant: dotWidth).isActive = true
        c.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        c.topAnchor.constraint(equalTo: b.bottomAnchor, constant: 5).isActive = true
        
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.topAnchor.constraint(equalTo: self.profileImg.bottomAnchor, constant: 15).isActive = true
        v.leadingAnchor.constraint(equalTo: self.profileImg.leadingAnchor).isActive = true
        v.widthAnchor.constraint(equalToConstant: 25).isActive = true
        v.heightAnchor.constraint(equalToConstant: 30).isActive = true
        v.isHidden = true
        return v
    }()
    
    var share = UIImageView(image: UIImage(named: "newShareV1"))
    
    
    let comments = UIImageView(image: UIImage(named: "newCommentsV1"))
    let commentsCounter = UILabel()
    
    let postDateLabel = UILabel(frame: .zero)
    let usernameLabel = UILabel(frame: .zero)
    
    var currentVideoData: NSMutableDictionary?
    
    let profileImg = UIImageView()
    
    
    let descriptionTextView = UITextView(frame: CGRect(origin: CGPoint(x: 300,y: 300), size: .zero))
    
    let heartImageView = UIImageView(image: UIImage(named: "newHeartV5"), highlightedImage: UIImage(named: "newHeartV5Red"))
    let likeCounter = UILabel()
    
    var isVideoLiked: Bool = false {
        didSet{
            DispatchQueue.main.async {
                self.heartImageView.isHighlighted = self.isVideoLiked
            }
        }
    }
    
    var isPaused: Bool = true {
        didSet {
            if isPaused {
                self.player.pause()
                pause.isHidden = false
            }else{
//                self.player.play()
                self.player.playImmediately(atRate: 1)
                pause.isHidden = true
            }
        }
    }
    
    
    func setupNewVideo(fromDict videoData: NSMutableDictionary) {
        
        self.playerLayer.frame = self.bounds
        
        currentVideoData = videoData
        
        if let video_url = videoData["video_url"] as? String {
            let remoteAsset = AVAsset(url: URL(string: video_url)!)
            let newPlayer = AVPlayerItem(asset: remoteAsset)
            self.player.replaceCurrentItem(with: newPlayer)
        } else {
            print("There is no video_url so we are fetching form server.")
            let targetEndpointString = FlykConfig.mainEndpoint+"/video/"
            let videoFilename =  videoData["video_filename"] as! String
            let remoteAssetUrl = URL(string: targetEndpointString + videoFilename)!
            let remoteAsset = AVAsset(url: remoteAssetUrl)
            
            let newPlayer = AVPlayerItem(asset: remoteAsset)
            self.player.replaceCurrentItem(with: newPlayer)
        }
        
        
        if let username = videoData["username"] as? String {
            self.usernameLabel.text = username
        }else{
            print("username failed")
        }
        
        if let postDateString = videoData["post_date"] as? String {
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
            
            if let postDate = formatter.date(from: postDateString) {
                let dateStamp = String(postDate.description.split(separator: " ")[0])
                
                let secondsSincePost = abs(postDate.timeIntervalSinceNow)
                let minutes = Int(secondsSincePost/60)
                var dateStringToSet: String!
                if minutes < 1 {
                    dateStringToSet = "Less than a minute ago"
                }else if minutes == 1 {
                    dateStringToSet = "1 minute ago"
                }else if minutes < 60 {
                    dateStringToSet = String(minutes) + " minutes ago"
                }else{
                    let hours = minutes / 60
                    if hours == 1 {
                        dateStringToSet = "1 hour ago"
                    } else if hours < 24 {
                        dateStringToSet = String(hours) + " hours ago"
                    } else {
                        let days = hours/24
                        if days == 1 {
                            dateStringToSet = "1 day ago"
                        }else if days < 7 {
                            dateStringToSet = String(days) + " days ago"
                        }else {
                            let weeks = days/7
                            if weeks == 1 {
                                dateStringToSet = "1 week ago"
                            } else {
                                dateStringToSet = dateStamp
                            }
                        }
                    }
                }
                self.postDateLabel.text = dateStringToSet
            }
            
        }
        
        if let descriptionText = videoData["video_description"] as? String {
             self.descriptionTextView.text = descriptionText.decodeHTML()
        }
//        print(self.descriptionTextView.attributedText!.size())
//        self.descriptionTextView.frame.size = self.descriptionTextView.attributedText!.size()
        if let isLikedByUser = videoData["is_liked_by_user"] as? Bool {
            self.isVideoLiked = isLikedByUser
        }
        
        if let profile_img_filename = videoData["profile_img_filename"] as? String {
            print("PROFIELE IMG FILENAME ESITS")
            // LOAD FROM URL
            let pImgURL = URL(string: FlykConfig.mainEndpoint+"/profile/photo/"+profile_img_filename)!
            URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    self.profileImg.image = UIImage(data: data!)
                }
            }).resume()
            
        }else{
            self.profileImg.image = FlykConfig.defaultProfileImage
        }
        
        if let comments_count = videoData["comments_count"] as? Int {
            var countText: String?
            if comments_count >= 1000 {
                let thousands = Float(comments_count)/1000
                countText = String(format: "%.1fK", thousands)
                if thousands >= 1000 {
                    let millions = thousands / 1000
                    countText = String(format: "%.1fM", millions)
                }
            }else {
                countText = String(comments_count)
            }
            commentsCounter.text = countText
//            commentsCounter.text = "500K"
        }
        
        if let likes_count = videoData["likes_count"] as? Int {
            var likesText: String?
            if likes_count >= 1000 {
                let thousands = Float(likes_count)/1000
                likesText = String(format: "%.1fK", thousands)
                if thousands >= 1000 {
                    let millions = thousands / 1000
                    likesText = String(format: "%.1fM", millions)
                }
            }else {
                likesText = String(likes_count)
            }
            likeCounter.text = likesText

            // UPDATE THE CONSTRAINT CONSTANT TO KEEP TEXT WITHIN IMAGE
            if let charCount = likeCounter.text?.count {
                if charCount > 2 {
                    self.likeCounterCenterYConstraint.constant = -7
                }else{
                    self.likeCounterCenterYConstraint.constant = -3
                }
            }
        }
        
        if let user_id = videoData["user_id"] as? String {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if (appDelegate.currentUserAccount.value(forKey: "user_id") as? String) == user_id {
                self.moreOptions.isHidden = false
            }
        }
    }
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        player.automaticallyWaitsToMinimizeStalling = false
        playerLayer.player = player
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspectFill
        
        addOverlay()
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePauseTapGesture(tapGesture:))))
    }
    
    @objc func handlePauseTapGesture(tapGesture: UITapGestureRecognizer){
//        if self.player.isPlaying {
//            self.player.pause()
//            self.pause.isHidden = false
//        }else{
//            self.player.play()
//            self.pause.isHidden = true
//        }
        self.isPaused = !self.isPaused
    }
    
    func addOverlay() {
        profileImg.contentMode = .scaleAspectFill
        profileImg.clipsToBounds = true
        profileImg.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        profileImg.layer.cornerRadius = 25
        self.addSubview(profileImg)
        profileImg.translatesAutoresizingMaskIntoConstraints = false
        profileImg.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        profileImg.topAnchor.constraint(equalTo: self.topAnchor, constant: 40).isActive = true
        profileImg.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImg.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileImg.isUserInteractionEnabled = true
//        profileImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImgTapGesture(tapGesture:))))
        

        self.addSubview(postDateLabel)
        postDateLabel.translatesAutoresizingMaskIntoConstraints = false
        postDateLabel.leadingAnchor.constraint(equalTo: profileImg.trailingAnchor, constant: 8).isActive = true
        postDateLabel.bottomAnchor.constraint(equalTo: profileImg.centerYAnchor).isActive = true
//        postDateLabel.text = ""// "5 days ago"
//        let newSize = postDateLabel.attributedText!.size()
//        postDateLabel.frame.size = newSize
        postDateLabel.font = UIFont.systemFont(ofSize: 13)
        postDateLabel.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        
        
        self.usernameLabel.isUserInteractionEnabled = true
        self.addSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.leadingAnchor.constraint(equalTo: profileImg.trailingAnchor, constant: 8).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: postDateLabel.bottomAnchor).isActive = true
//        usernameLabel.text = ""
//        usernameLabel.frame.size = usernameLabel.attributedText!.size()
        usernameLabel.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        
        
        self.addSubview(descriptionTextView)
        
        descriptionTextView.text = ""
        descriptionTextView.font = UIFont.systemFont(ofSize: 14)
        descriptionTextView.isScrollEnabled = false
        
        let newDescriptionSize = descriptionTextView.attributedText!.size()
        
        descriptionTextView.frame.size = newDescriptionSize
        descriptionTextView.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = false
        
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
//        description.heightAnchor.constraint(equalToConstant: description.contentSize.height).isActive = true
        descriptionTextView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.55).isActive = true
        

        /*
            BUTTONS
        */
        self.addSubview(share)
        self.addSubview(heartImageView)
        self.addSubview(comments)
        setupLikeImgView()
        setupShareImgView()
        setupCommentImgView()

    }
    
    let hiButtonWidth: CGFloat = 30
    let hiButtonButtonConst: CGFloat = -10
    let hiButtonGap: CGFloat = 15
    
    var likeCounterCenterYConstraint: NSLayoutConstraint!
    
    func setupLikeImgView(){
        heartImageView.contentMode = .scaleAspectFit
        heartImageView.translatesAutoresizingMaskIntoConstraints = false
//        heartImageView.leadingAnchor.constraint(equalTo: share.trailingAnchor, constant: 15).isActive = true
        heartImageView.leadingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: 15).isActive = true
        heartImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: hiButtonButtonConst).isActive = true
        heartImageView.heightAnchor.constraint(equalToConstant: hiButtonWidth).isActive = true
        heartImageView.widthAnchor.constraint(equalToConstant: hiButtonWidth).isActive = true
        heartImageView.alpha = 0.8
        heartImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHeartTap(tapGesture:))))
        heartImageView.isUserInteractionEnabled = true
        
        
        /* LIKE COUNTER */
        likeCounter.adjustsFontSizeToFitWidth = true
        heartImageView.addSubview(likeCounter)
        //        commentsCounter.text = "500"
        likeCounter.textColor = .white
        likeCounter.translatesAutoresizingMaskIntoConstraints = false
        likeCounter.centerXAnchor.constraint(equalTo: heartImageView.centerXAnchor, constant: 0).isActive = true
        
        likeCounterCenterYConstraint = likeCounter.centerYAnchor.constraint(equalTo: heartImageView.centerYAnchor, constant: -3) //-6
        likeCounterCenterYConstraint.isActive = true
        
        likeCounter.widthAnchor.constraint(lessThanOrEqualTo: heartImageView.widthAnchor, multiplier: 0.7).isActive = true
        likeCounter.heightAnchor.constraint(lessThanOrEqualTo: heartImageView.heightAnchor, multiplier: 0.8).isActive = true
    }
    
    func setupCommentImgView(){
        comments.contentMode = .scaleAspectFit
        comments.translatesAutoresizingMaskIntoConstraints = false
        comments.leadingAnchor.constraint(equalTo: heartImageView.trailingAnchor, constant: hiButtonGap).isActive = true
//        comments.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -60).isActive = true
        comments.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: hiButtonButtonConst).isActive = true
        comments.heightAnchor.constraint(equalToConstant: hiButtonWidth).isActive = true
        comments.widthAnchor.constraint(equalToConstant: hiButtonWidth).isActive = true
        comments.alpha = 0.8
        comments.isUserInteractionEnabled = true
        
        
        commentsCounter.adjustsFontSizeToFitWidth = true
        comments.addSubview(commentsCounter)
        //        commentsCounter.text = "500"
        commentsCounter.textColor = .white
        commentsCounter.translatesAutoresizingMaskIntoConstraints = false
        commentsCounter.centerXAnchor.constraint(equalTo: comments.centerXAnchor, constant: 0).isActive = true
        commentsCounter.centerYAnchor.constraint(equalTo: comments.centerYAnchor, constant: -3).isActive = true
        commentsCounter.widthAnchor.constraint(lessThanOrEqualTo: comments.widthAnchor, multiplier: 0.8).isActive = true
        commentsCounter.heightAnchor.constraint(lessThanOrEqualTo: comments.heightAnchor, multiplier: 0.8).isActive = true
        
    }
    
    func setupShareImgView(){
        share.contentMode = .scaleAspectFit
        share.translatesAutoresizingMaskIntoConstraints = false
        share.leadingAnchor.constraint(equalTo: comments.trailingAnchor, constant: hiButtonGap).isActive = true
        share.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: hiButtonButtonConst).isActive = true
        share.heightAnchor.constraint(equalToConstant: hiButtonWidth).isActive = true
        share.widthAnchor.constraint(equalToConstant: hiButtonWidth).isActive = true
        share.alpha = 0.8
        share.isUserInteractionEnabled = true
    }

    
    @objc func handleHeartTap(tapGesture: UITapGestureRecognizer){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.triggerSignInIfNoAccount(customMessgae: "Sign In To Like Posts") {
            if let _ = tapGesture.view as? UIImageView {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                
                if !isVideoLiked /* LIKE VIDEO */ {
                    self.isVideoLiked = true
                    
                    let videoListURL = URL(string: FlykConfig.mainEndpoint+"/video/like")!
                    
                    var request = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
                    
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    let parameters: NSDictionary = ["videoId": self.currentVideoData?["video_id"]]
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
                            self.isVideoLiked = false
                            return
                        }
                        guard let response = response as? HTTPURLResponse else {
                            print("not httpurlresponse...!")
                            return;
                        }
                        
                        if(response.statusCode == 200) {
                            DispatchQueue.main.async {
                                
                                self.currentVideoData?["is_liked_by_user"]? = true
                                // NEED TO PASS THIS LIKE UP TO THE PARENT
                                if var curCount = self.currentVideoData?["likes_count"] as? Int {
                                    curCount += 1
                                    self.currentVideoData?["likes_count"] = curCount
                                    self.likeCounter.text = String(curCount)
                                }
                            }
                            //Worked....
                        }else{
                            print("Response not 200", response)
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                            self.isVideoLiked = false
                        }
                        
                        }.resume()
                    
                    
                }else{ // UNLIKE VIDEO
                    self.isVideoLiked = false
                    
                    let videoListURL = URL(string: FlykConfig.mainEndpoint+"/video/unlike")!
                    
                    var request = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
                    
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    let parameters: NSDictionary = ["videoId": self.currentVideoData?["video_id"]]
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
                            self.isVideoLiked = true
                            return
                        }
                        guard let response = response as? HTTPURLResponse else {
                            print("not httpurlresponse...!")
                            return;
                        }
                        
                        if(response.statusCode == 200) {
                            //Worked....
                            DispatchQueue.main.async {
                                self.currentVideoData?["is_liked_by_user"]? = false
//                                self.currentVideoData?.setValue(false, forKeyPath: "is_liked_by_user")
                                // NEED TO PASS THIS DISLIKE UP TO THE PARENT
                                if var curCount = self.currentVideoData?["likes_count"] as? Int {
                                    curCount -= 1
                                    self.currentVideoData?["likes_count"] = curCount
                                    self.likeCounter.text = String(curCount)
                                }
                            }
                        }else{
                            print("Response not 200", response)
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                            self.isVideoLiked = true
                        }
                        
                        }.resume()
                    
                    
                    
                    
                    
                    
                }
               
                
                
            }
        }
    }
//    @objc func profileImgTapGesture(tapGesture: UITapGestureRecognizer){
//
//    }
    
    func addDidEndObserver(){
        if let _ = self.player.currentItem {
            videoDidEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
                self?.player.seek(to: CMTime.zero)
                self?.player.play()
            }
        }
    }
    
    func removeDidEndObserver(){
        if let videoDidEndObserver = self.videoDidEndObserver {
            NotificationCenter.default.removeObserver(videoDidEndObserver)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeDidEndObserver()
        self.player.replaceCurrentItem(with: nil)
        self.usernameLabel.text = ""
        self.descriptionTextView.text = ""
        self.likeCounter.text = ""
        self.commentsCounter.text = ""
        self.postDateLabel.text = ""
        self.profileImg.image = nil
        self.moreOptions.isHidden = true


        
        for v in [
            self.usernameLabel,
            self.profileImg,
            self.share,
            self.comments,
            self.moreOptions ] {
            for gestRec in v.gestureRecognizers ?? [] {
                v.removeGestureRecognizer(gestRec)
            }
        }
        
    }
    


        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

