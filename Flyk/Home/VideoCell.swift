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
    
    var pause: UIImageView!
    var share: UIImageView!
    
    
    let comments = UIImageView(image: UIImage(named: "commentsImg"))
    
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
    
    func addOverlay(){
        let profileImg = UIImageView()
        let pImgURL = URL(string: "https://swiftytest.uc.r.appspot.com/profilePhotos/polar_bear.jpg")
        URLSession.shared.dataTask(with:  pImgURL!, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                profileImg.image = UIImage(data: data!)
            }
        }).resume()
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
        profileImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImgTapGesture(tapGesture:))))
        
        let profileName = UILabel(frame: .zero)
        self.addSubview(profileName)
        profileName.translatesAutoresizingMaskIntoConstraints = false
        profileName.leadingAnchor.constraint(equalTo: profileImg.trailingAnchor, constant: 8).isActive = true
        profileName.bottomAnchor.constraint(equalTo: profileImg.centerYAnchor).isActive = true
        profileName.text = "5 days ago"//"@polarBear"
        let newSize = profileName.attributedText!.size()
        profileName.frame.size = newSize
        profileName.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        
        let postDate = UILabel(frame: .zero)
        self.addSubview(postDate)
        postDate.translatesAutoresizingMaskIntoConstraints = false
        postDate.leadingAnchor.constraint(equalTo: profileImg.trailingAnchor, constant: 8).isActive = true
        postDate.topAnchor.constraint(equalTo: profileName.bottomAnchor).isActive = true
        postDate.text = "@polarBear"//"5 days ago"
        let newPostSize = postDate.attributedText!.size()
        postDate.frame.size = newPostSize
        postDate.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        
        
        let description = UITextView(frame: CGRect(origin: CGPoint(x: 300,y: 300), size: .zero))
        self.addSubview(description)
        
        description.text = "This is a video hello world at some point this should spill to a second line"
        description.font = description.font?.withSize(14)
        description.isScrollEnabled = false
        
        let newDescriptionSize = description.attributedText!.size()
        
        description.frame.size = newDescriptionSize
        description.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)
        description.backgroundColor = .clear
        description.isEditable = false
        description.isSelectable = false
        
        description.translatesAutoresizingMaskIntoConstraints = false
        description.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        description.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
//        description.heightAnchor.constraint(equalToConstant: description.contentSize.height).isActive = true
        description.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6).isActive = true
        
        share = UIImageView(image: UIImage(named: "shareV1"))
        share.contentMode = .scaleAspectFit
        self.addSubview(share)
        share.translatesAutoresizingMaskIntoConstraints = false
        share.leadingAnchor.constraint(equalTo: description.trailingAnchor, constant: 15).isActive = true
        share.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        share.heightAnchor.constraint(equalToConstant: 40).isActive = true
        share.widthAnchor.constraint(equalToConstant: 40).isActive = true
        share.alpha = 0.8
        share.isUserInteractionEnabled = true
        
        let heart = UIImageView(image: UIImage(named: "heart_v2"), highlightedImage: UIImage(named: "heart_red_v2"))
        heart.contentMode = .scaleAspectFit
        self.addSubview(heart)
        heart.translatesAutoresizingMaskIntoConstraints = false
        heart.leadingAnchor.constraint(equalTo: share.trailingAnchor, constant: 15).isActive = true
        heart.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        heart.heightAnchor.constraint(equalToConstant: 40).isActive = true
        heart.widthAnchor.constraint(equalToConstant: 40).isActive = true
        heart.alpha = 0.8
        heart.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleHeartTap(tapGesture:))))
        heart.isUserInteractionEnabled = true
        
        
        
        comments.contentMode = .scaleAspectFit
        self.addSubview(comments)
        comments.translatesAutoresizingMaskIntoConstraints = false
        comments.leadingAnchor.constraint(equalTo: share.trailingAnchor, constant: 15).isActive = true
        comments.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -60).isActive = true
        comments.heightAnchor.constraint(equalToConstant: 40).isActive = true
        comments.widthAnchor.constraint(equalToConstant: 40).isActive = true
        comments.alpha = 0.8
        comments.isUserInteractionEnabled = true
        
        let commentsCounter = UILabel()
        commentsCounter.adjustsFontSizeToFitWidth = true
        comments.addSubview(commentsCounter)
        commentsCounter.text = "500"
        commentsCounter.textColor = .white
        commentsCounter.translatesAutoresizingMaskIntoConstraints = false
        commentsCounter.centerXAnchor.constraint(equalTo: comments.centerXAnchor, constant: -2).isActive = true
        commentsCounter.centerYAnchor.constraint(equalTo: comments.centerYAnchor, constant: -3).isActive = true
        commentsCounter.widthAnchor.constraint(lessThanOrEqualTo: comments.widthAnchor, multiplier: 0.6).isActive = true
        commentsCounter.heightAnchor.constraint(lessThanOrEqualTo: comments.heightAnchor, multiplier: 0.8).isActive = true
        
        
        
        pause = UIImageView(image: UIImage(named: "pause"))
        pause.contentMode = .scaleAspectFit
        self.addSubview(pause)
        pause.translatesAutoresizingMaskIntoConstraints = false
        pause.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        pause.centerYAnchor.constraint(equalTo: profileImg.centerYAnchor).isActive = true
        pause.heightAnchor.constraint(equalToConstant: 30).isActive = true
        pause.widthAnchor.constraint(equalToConstant: 30).isActive = true
        pause.alpha = 0.7
        pause.isHidden = true
        
    }
    

    
    @objc func handleHeartTap(tapGesture: UITapGestureRecognizer){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.triggerSignInIfNoAccount(customMessgae: "Sign In To Like Posts") {
            if let imgView = tapGesture.view as? UIImageView{
                imgView.isHighlighted = !imgView.isHighlighted
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
    @objc func profileImgTapGesture(tapGesture: UITapGestureRecognizer){
        
    }
    
    func addDidEndObserver(){
        if let currentItem = self.player.currentItem {
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
        print("REUSE", (self.player.currentItem?.asset as! AVURLAsset).url)
        super.prepareForReuse()
        self.removeDidEndObserver()
        self.player.replaceCurrentItem(with: nil)
    }
    


        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

