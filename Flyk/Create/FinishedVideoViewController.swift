//
//  FinishedVideoViewController.swift
//  Flyk
//
//  Created by Edward Chapman on 7/14/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation



class FinishedVideoViewController : UIViewController, UITextViewDelegate {
    var finishedViewURL: URL? {
        didSet{
            self.videoLoadingSpinner.stopAnimating()
            playerLayer.player = videoPlaybackPlayer
        }
    }
    let playerLayer = AVPlayerLayer()
    var videoPlaybackViewLeadingAnchor : NSLayoutConstraint!
    var videoPlaybackViewTopAnchor : NSLayoutConstraint!
    var videoPlaybackViewWidthAnchorSmall : NSLayoutConstraint!
    var videoPlaybackViewWidthAnchorBig : NSLayoutConstraint!
    var videoPlaybackViewHeightAnchor : NSLayoutConstraint!
    let descriptionLabel = UILabel()
    let characterCounter = UILabel()
    let descriptionInput = UITextView()
    
    let videoLoadingSpinner = UIActivityIndicatorView(style: .white)
    
    lazy var videoPlaybackView : UIView = {
        let videoPlaybackView = UIView()
        self.playerLayer.backgroundColor = UIColor.flykLightDarkGrey.cgColor
        videoPlaybackView.layer.cornerRadius = 8
        videoPlaybackView.clipsToBounds = true
        videoPlaybackView.layer.addSublayer(playerLayer)
        self.view.addSubview(videoPlaybackView)
        videoPlaybackView.translatesAutoresizingMaskIntoConstraints = false
        videoPlaybackViewLeadingAnchor = videoPlaybackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8)
        videoPlaybackViewLeadingAnchor.isActive = true
        
        videoPlaybackViewTopAnchor = videoPlaybackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8)
        videoPlaybackViewTopAnchor.isActive = true
        
        videoPlaybackViewWidthAnchorSmall = videoPlaybackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4)
        videoPlaybackViewWidthAnchorSmall.isActive = true
        
        videoPlaybackViewWidthAnchorBig = videoPlaybackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -16)
        videoPlaybackViewWidthAnchorBig.isActive = false
        
        videoPlaybackViewHeightAnchor = videoPlaybackView.heightAnchor.constraint(equalTo: videoPlaybackView.widthAnchor, multiplier: 16/9)
        videoPlaybackViewHeightAnchor.isActive = true
//        self.view.layoutIfNeeded()
//        videoPlaybackView.frame = self.view.frame
        self.view.addSubview(self.videoLoadingSpinner)
        self.videoLoadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        self.videoLoadingSpinner.centerXAnchor.constraint(equalTo: videoPlaybackView.centerXAnchor).isActive = true
        self.videoLoadingSpinner.centerYAnchor.constraint(equalTo: videoPlaybackView.centerYAnchor).isActive = true
        self.videoLoadingSpinner.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.videoLoadingSpinner.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.videoLoadingSpinner.startAnimating()
        self.view.layoutSubviews()
        
        
        playerLayer.frame = videoPlaybackView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        return videoPlaybackView
    }()
    lazy var videoPlaybackPlayer: AVPlayer = {
        let videoPlaybackPlayer = AVPlayer(url: finishedViewURL!)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object:   videoPlaybackPlayer.currentItem, queue: .main) { [weak self] _ in
            self?.videoPlaybackPlayer.seek(to: CMTime.zero)
            self?.videoPlaybackPlayer.play()
        }
        videoPlaybackPlayer.play()
        return videoPlaybackPlayer
    }()
    
    let backButton = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.flykDarkGrey
        backButton.layer.cornerRadius = 45/2
        backButton.layer.borderColor = UIColor.white.cgColor
        backButton.layer.borderWidth = 1
        backButton.backgroundColor = UIColor.flykMediumGrey
        self.view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15).isActive = true
        backButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor).isActive = true
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackButtonTap(tapGesture:))))
        
        setupSwitches()
        setupUploadButtons()
        
        
        descriptionInput.backgroundColor = .clear
        descriptionInput.textColor = .white
        descriptionInput.delegate = self
//        descriptionInput.font = descriptionInput.font?.withSize(18)
        self.view.addSubview(descriptionInput)
        descriptionInput.translatesAutoresizingMaskIntoConstraints = false
        descriptionInput.topAnchor.constraint(equalTo: self.videoPlaybackView.topAnchor).isActive = true
        descriptionInput.bottomAnchor.constraint(equalTo: self.videoPlaybackView.bottomAnchor).isActive = true
        descriptionInput.leadingAnchor.constraint(equalTo: self.videoPlaybackView.trailingAnchor, constant: 8).isActive = true
        descriptionInput.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6, constant: -20).isActive = true
        
        
        
        
        descriptionLabel.frame = CGRect(x: descriptionInput.textContainerInset.left, y: descriptionInput.textContainerInset.top, width: 80, height: 30)
        descriptionLabel.text = "Description"
        descriptionLabel.font = descriptionLabel.font.withSize(17)
        descriptionLabel.textColor = .flykGrey
        descriptionLabel.frame.size = descriptionLabel.attributedText!.size()
        descriptionInput.addSubview(descriptionLabel)
        
        
        
        
        descriptionInput.font = descriptionLabel.font
        
        characterCounter.textColor = .darkGray
        characterCounter.font = characterCounter.font.withSize(14)
        descriptionInput.addSubview(characterCounter)
        
        
        
        videoPlaybackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleVideoPlaybackViewTap(tapGesture:))))
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMainViewTap(tapGesture:))))
        
        
        
        
    }
    
    func setupUploadButtons(){
        let uploadLater = UIView()
        self.view.addSubview(uploadLater)
        uploadLater.backgroundColor = .flykDarkWhite
        uploadLater.layer.cornerRadius = 12
        uploadLater.translatesAutoresizingMaskIntoConstraints = false
        uploadLater.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8).isActive = true
        uploadLater.bottomAnchor.constraint(equalTo: self.backButton.topAnchor, constant: -20).isActive = true
        uploadLater.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5, constant: -12).isActive = true
        uploadLater.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let uploadLaterText = UILabel()
        uploadLaterText.text = "Upload Later"
        uploadLaterText.font = UIFont.boldSystemFont(ofSize: 16.0)
        uploadLaterText.textColor = .flykDarkGrey
        uploadLaterText.textAlignment = .center
        uploadLater.addSubview(uploadLaterText)
        uploadLaterText.translatesAutoresizingMaskIntoConstraints = false
        uploadLaterText.leadingAnchor.constraint(equalTo: uploadLater.leadingAnchor).isActive = true
        uploadLaterText.trailingAnchor.constraint(equalTo: uploadLater.trailingAnchor).isActive = true
        uploadLaterText.topAnchor.constraint(equalTo: uploadLater.topAnchor).isActive = true
        uploadLaterText.bottomAnchor.constraint(equalTo: uploadLater.bottomAnchor).isActive = true
        uploadLater.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLaterUpload)))
        
        
        let uploadNow = UIView()
        uploadNow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        self.view.addSubview(uploadNow)
        uploadNow.backgroundColor = .flykBlue
        uploadNow.layer.cornerRadius = 12
        uploadNow.translatesAutoresizingMaskIntoConstraints = false
        uploadNow.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8).isActive = true
        uploadNow.bottomAnchor.constraint(equalTo: uploadLater.bottomAnchor, constant: 0).isActive = true
        uploadNow.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5, constant: -12).isActive = true
        uploadNow.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let uploadNowText = UILabel()
        uploadNowText.text = "Upload Now"
        uploadNowText.font = UIFont.boldSystemFont(ofSize: 16.0)
        uploadNowText.textColor = .white
        uploadNowText.textAlignment = .center
        uploadNow.addSubview(uploadNowText)
        uploadNowText.translatesAutoresizingMaskIntoConstraints = false
        uploadNowText.leadingAnchor.constraint(equalTo: uploadNow.leadingAnchor).isActive = true
        uploadNowText.trailingAnchor.constraint(equalTo: uploadNow.trailingAnchor).isActive = true
        uploadNowText.topAnchor.constraint(equalTo: uploadNow.topAnchor).isActive = true
        uploadNowText.bottomAnchor.constraint(equalTo: uploadNow.bottomAnchor).isActive = true
    }
    
    
    func playbackViewStoreAnimation(){
        if (self.tabBarController?.tabBar.isHidden)! {
            self.view.isUserInteractionEnabled = false
            self.tabBarController?.showTabBarView()
            
            self.videoPlaybackViewLeadingAnchor.isActive = false
            self.videoPlaybackViewTopAnchor.isActive = false
            self.videoPlaybackViewWidthAnchorSmall.isActive = false
            self.videoPlaybackViewWidthAnchorBig.isActive = false
            let startFrame = self.videoPlaybackView.frame
            self.videoPlaybackView.frame = self.view.convert(startFrame, to: self.tabBarController?.view)
            self.tabBarController?.view.addSubview(videoPlaybackView)
            
            let newPlayBackWidth: CGFloat = 18
            let newPlaybackSize = CGSize(width: newPlayBackWidth, height: newPlayBackWidth*(16/9))
            UIView.animate(withDuration: 1, animations: {
                //                self.view.layoutIfNeeded()
                
                self.videoPlaybackView.frame.size = newPlaybackSize
                self.videoPlaybackView.frame.origin = CGPoint(
                    x: (self.tabBarController?.tabBar.frame.maxX)! - 40,
                    y: (self.tabBarController?.tabBar.frame.minY)! + 5
                )
                
                //ANIMATE THE PREVIEW VIEW GOING TOWARDS USER PROFILE
                // deactivate top anchor
                // deactivate leading anchor
                // deactivate width anchor
                // deactivate height anchor
                
            }) { (finished) in
                
                //                if let takeVidVCIndex = self.navigationController?.viewControllers.firstIndex(where: { (curVc) -> Bool in
                //                    if curVc is TakeVideoViewController {
                //                        return true
                //                    }else{
                //                        return false
                //                    }
                //                }) {
                //
                //                }
                self.videoPlaybackView.removeFromSuperview()
                self.tabBarController!.selectedIndex = 4
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }else{
            //            self.tabBarController?.hideTabBarView()
            //            generator.impactOccurred()
        }
    }
    
    
    @objc func handleLaterUpload(tapGesture: UITapGestureRecognizer){
        if finishedViewURL == nil {return}
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        playbackViewStoreAnimation()
        
        
    }
    @objc func handleUploadTap(tapGesture: UITapGestureRecognizer){
        if finishedViewURL == nil {return}
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        playbackViewStoreAnimation()
        //HERE WE PASS THE STUFF TO ALLOW THE UPLOAD TO HAPPEN

        let url = "https://upload-dot-swiftytest.uc.r.appspot.com/upload"
//        let img = UIImage(contentsOfFile: fullPath)
        var data: NSData;
        do {
            try data = NSData(contentsOf: finishedViewURL!)
        }catch{
            print("URL FAIL")
            return
        }

        
        do {
            let boundary = "?????"
            var request = URLRequest(url: URL(string: url)!)
            request.timeoutInterval = 660
            request.httpMethod = "POST"
            request.httpBody = MultiPartPost.photoDataToFormData(data: data, boundary: boundary, fileName: "video") as Data
//            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            request.addValue("multipart/form-data;boundary=\"" + boundary+"\"",
                              forHTTPHeaderField: "Content-Type")
            request.addValue("video/mp4", forHTTPHeaderField: "mimeType")
            request.addValue(String((request.httpBody! as NSData).length), forHTTPHeaderField: "Content-Length")
            
            request.addValue("text/plain", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if error != nil || data == nil {
                    print("Client error!")
                    return
                }
                
                guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
                    print("Server error!")
//                    print(data, response, error)
                    return
                }
                print("SUCCESS")
            }
            print("Upload Started")
            task.resume()
            
            
            
            
        }catch{}
    }
    
    func setupSwitches(){
        let tandemSwitch = UISwitch(frame: .zero)
        self.view.addSubview(tandemSwitch)
        tandemSwitch.translatesAutoresizingMaskIntoConstraints = false
        tandemSwitch.frame.size = tandemSwitch.intrinsicContentSize
        tandemSwitch.tintColor = .flykLightDarkGrey
        
        let superWidth = self.view.frame.width
        let videoPlayerBottom = 0.4*superWidth*(16/9)+8
        let topConst = videoPlayerBottom+40
        tandemSwitch.onTintColor = .flykBlue
        tandemSwitch.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(topConst)).isActive = true
        tandemSwitch.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        tandemSwitch.widthAnchor.constraint(equalToConstant: tandemSwitch.intrinsicContentSize.width).isActive = true
        tandemSwitch.heightAnchor.constraint(equalToConstant: tandemSwitch.intrinsicContentSize.height).isActive = true
        
        let tandemSwitchLabel = UILabel(frame: .zero)
        tandemSwitchLabel.textColor = .flykDarkWhite
        self.view.addSubview(tandemSwitchLabel)
        tandemSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
        tandemSwitchLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        tandemSwitchLabel.trailingAnchor.constraint(equalTo: tandemSwitch.leadingAnchor, constant: -8).isActive = true
        tandemSwitchLabel.centerYAnchor.constraint(equalTo: tandemSwitch.centerYAnchor).isActive = true
        tandemSwitchLabel.text = "Allow Tandem"
        tandemSwitchLabel.adjustsFontSizeToFitWidth = true
        
        
        
        let commentsSwitch = UISwitch(frame: .zero)
        commentsSwitch.tintColor = .flykLightDarkGrey
        self.view.addSubview(commentsSwitch)
        commentsSwitch.translatesAutoresizingMaskIntoConstraints = false
        commentsSwitch.frame.size = commentsSwitch.intrinsicContentSize
        
//        let superWidth = self.view.frame.width
//        let videoPlayerBottom = 0.4*superWidth*(16/9)+8
//        let topConst = videoPlayerBottom+40
        commentsSwitch.onTintColor = .flykBlue
        commentsSwitch.topAnchor.constraint(equalTo: tandemSwitch.bottomAnchor, constant: 35).isActive = true
        commentsSwitch.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        commentsSwitch.widthAnchor.constraint(equalToConstant: commentsSwitch.intrinsicContentSize.width).isActive = true
        commentsSwitch.heightAnchor.constraint(equalToConstant: commentsSwitch.intrinsicContentSize.height).isActive = true
        
        let commentsSwitchLabel = UILabel(frame: .zero)
        commentsSwitchLabel.textColor = .flykDarkWhite
        self.view.addSubview(commentsSwitchLabel)
        commentsSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
        commentsSwitchLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        commentsSwitchLabel.trailingAnchor.constraint(equalTo: commentsSwitch.leadingAnchor, constant: -8).isActive = true
        commentsSwitchLabel.centerYAnchor.constraint(equalTo: commentsSwitch.centerYAnchor).isActive = true
        commentsSwitchLabel.text = "Allow Comments"
        commentsSwitchLabel.adjustsFontSizeToFitWidth = true
        
        
    }
    
    @objc func handleMainViewTap(tapGesture: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionLabel.isHidden = true
    }
    func textViewDidChange(_ textView: UITextView) {
        characterCounter.text = String(textView.text.count)
        let newSize = characterCounter.attributedText!.size()

        characterCounter.frame = CGRect(
            origin: CGPoint(
                x: characterCounter.superview!.bounds.maxX - newSize.width,
                y: characterCounter.superview!.bounds.maxY - newSize.height
            ),
            size: newSize
        )
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count == 0 {
            descriptionLabel.isHidden = false
        }
    }
    
    @objc func handleVideoPlaybackViewTap(tapGesture: UITapGestureRecognizer){
         self.view.endEditing(true)
        if self.videoPlaybackViewWidthAnchorSmall.isActive {
            self.videoPlaybackViewWidthAnchorSmall.isActive = false
            self.videoPlaybackViewWidthAnchorBig.isActive = true
            self.view.layoutSubviews()
            UIView.animate(withDuration: 0.3, animations: {
                self.videoPlaybackView.layer.sublayers![0].frame = self.videoPlaybackView.bounds
            })
        }else{
            self.videoPlaybackViewWidthAnchorBig.isActive = false
            self.videoPlaybackViewWidthAnchorSmall.isActive = true
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutSubviews()
                self.videoPlaybackView.layer.sublayers![0].frame = self.videoPlaybackView.bounds
            })
        }
    }
    
    @objc func handleBackButtonTap(tapGesture: UITapGestureRecognizer){
        if (self.navigationController?.viewControllers.contains(self))! {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
