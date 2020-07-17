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
        self.playerLayer.backgroundColor = UIColor.flykLightGrey.cgColor
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.flykDarkGrey
        let uploadButton = UIView(frame: CGRect(x: self.view.frame.maxX - 60, y: self.view.frame.maxY-60, width: 45, height: 45))
        uploadButton.layer.cornerRadius = 45/2
        uploadButton.layer.borderColor = UIColor.white.cgColor
        uploadButton.layer.borderWidth = 1
        uploadButton.backgroundColor = UIColor.flykBlue
        self.view.addSubview(uploadButton)
        uploadButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap(tapGesture:))))
        
        
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
        descriptionLabel.textColor = .gray
        descriptionLabel.frame.size = descriptionLabel.attributedText!.size()
        descriptionInput.addSubview(descriptionLabel)
        
        
        
        
        descriptionInput.font = descriptionLabel.font
        
        characterCounter.textColor = .darkGray
        characterCounter.font = characterCounter.font.withSize(14)
        descriptionInput.addSubview(characterCounter)
        
        
        videoPlaybackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleVideoPlaybackViewTap(tapGesture:))))
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMainViewTap(tapGesture:))))
        
    }
    
    @objc func handleMainViewTap(tapGesture: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("TEXTFIELDSHOULDBEGINEDITING")
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionLabel.isHidden = true
    }
    func textViewDidChange(_ textView: UITextView) {
        characterCounter.text = String(textView.text.count)
        let newSize = characterCounter.attributedText!.size()
        print(newSize)
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
    
    @objc func handleUploadTap(tapGesture: UITapGestureRecognizer){
        print("UPLOAD TAPPED")
    }
}
