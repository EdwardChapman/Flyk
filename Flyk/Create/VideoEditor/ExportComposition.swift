//
//  ExportComposition.swift
//  Flyk
//
//  Created by Edward Chapman on 7/12/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ExportCompositionController: UIViewController {
    
    var recordingUrlList : [URL] = []
    let videoPlaybackView = UIView()
    let videoPlaybackPlayer = AVPlayer()
    let videoOverlayView = UIView()
    
    var visibilityDurationStartTime = [UIView: Double]()
    var visibilityDurationEndTime = [UIView: Double]()
    
    var returnToForegroundObserver : NSObjectProtocol?
    var videoDidEndObserver: NSObjectProtocol?
    
    
    
    
    
    func setupPlaybackView(){
        
        let playerLayer = AVPlayerLayer(player: videoPlaybackPlayer)
        //        playerLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.layer.addSublayer(playerLayer)
        
        self.view.addSubview(videoPlaybackView)
        videoPlaybackView.translatesAutoresizingMaskIntoConstraints = false
        videoPlaybackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        videoPlaybackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        videoPlaybackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        videoPlaybackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        //        videoPlaybackView.heightAnchor.constraint(equalToConstant: self.view.frame.height + (self.tabBarController?.tabBar.frame.height)!).isActive = true
        updateViewConstraints()
        self.view.layoutSubviews()
        
        playerLayer.frame = CGRect(x: 0, y: 0, width: videoPlaybackView.frame.width, height: videoPlaybackView.frame.height)
        
        
        playerLayer.videoGravity = .resizeAspectFill
        videoPlaybackPlayer.play()
        
        videoDidEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object:   videoPlaybackPlayer.currentItem, queue: .main) { [weak self] _ in
            self?.videoPlaybackPlayer.seek(to: CMTime.zero)
            
            
            let curVideoPlayerLength = (self!.videoPlaybackPlayer.currentItem?.duration.seconds)!
            UIView.animateKeyframes(withDuration: curVideoPlayerLength, delay: 0, options: .allowUserInteraction, animations: {
                
                for element in self!.videoOverlayView.subviews{
                    if let elementStartTime = self!.visibilityDurationStartTime[element] {
                        UIView.addKeyframe(withRelativeStartTime: (elementStartTime/curVideoPlayerLength), relativeDuration: 0, animations: {
                            element.alpha = 1
                        })
                    } else {
                        element.alpha = 1
                    }
                    if let elementEndTime = self!.visibilityDurationEndTime[element] {
                        UIView.addKeyframe(withRelativeStartTime: (elementEndTime/curVideoPlayerLength), relativeDuration: 0, animations: {
                            element.alpha = 0.0
                        })
                    }
                }
            }, completion: { finished in
                
            })
            self?.videoPlaybackPlayer.play()
        }
        
        
        returnToForegroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            self.videoPlaybackPlayer.seek(to: self.videoPlaybackPlayer.currentItem!.duration)
            self.videoPlaybackPlayer.play()
            // do whatever you want when the app is brought back to the foreground
        }
        
    }
}
