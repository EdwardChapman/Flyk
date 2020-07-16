//
//  FinishedVideoViewController.swift
//  Flyk
//
//  Created by Edward Chapman on 7/14/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation

class FInishedViewViewController : UIViewController {
    var finishedViewURL: URL?
    let videoPlaybackView = UIView()
    lazy var videoPlaybackPlayer: AVPlayer = {
        return AVPlayer(url: finishedViewURL!)
    }()
    
    func setupPlaybackView(){
        let playerLayer = AVPlayerLayer(player: videoPlaybackPlayer)

        self.view.addSubview(videoPlaybackView)
        videoPlaybackView.layer.addSublayer(playerLayer)
        videoPlaybackView.frame = self.view.frame
        
        self.view.layoutSubviews()
        
        playerLayer.frame = CGRect(x: 0, y: 0, width: videoPlaybackView.frame.width, height: videoPlaybackView.frame.height)
        
        
        playerLayer.videoGravity = .resizeAspectFill
        videoPlaybackPlayer.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object:   videoPlaybackPlayer.currentItem, queue: .main) { [weak self] _ in
            self?.videoPlaybackPlayer.seek(to: CMTime.zero)
            
            self?.videoPlaybackPlayer.play()
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaybackView()
        
        let uploadButton = UIView(frame: CGRect(x: self.view.frame.maxX - 60, y: self.view.frame.maxY-60, width: 45, height: 45))
        uploadButton.layer.cornerRadius = 45/2
        uploadButton.layer.borderColor = UIColor.white.cgColor
        uploadButton.layer.borderWidth = 1
        uploadButton.backgroundColor = UIColor.green
        self.view.addSubview(uploadButton)
        uploadButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap(tapGesture:))))
        
    }
    
    @objc func handleUploadTap(tapGesture: UITapGestureRecognizer){
        print("UPLOAD TAPPED")
    }
}
