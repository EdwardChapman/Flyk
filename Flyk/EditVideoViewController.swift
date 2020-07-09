//
//  ThirdViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation


class EditVideoViewController: UIViewController {
    
    var recordingUrlList : [URL] = []
    var recordingLengthList : [Double] = []
    
    
    func displayRecordedVideos(){
        
        let videoPlaybackView = UIView()
        
        let videoPlaybackPlayer = AVPlayer(url: recordingUrlList[0])
        
        let playerLayer = AVPlayerLayer(player: videoPlaybackPlayer)
        //        playerLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        videoPlaybackView.layer.addSublayer(playerLayer)
        
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
        
        let goBack = UIView(frame: CGRect(x: 50, y: 50, width: 70, height: 70))
        goBack.backgroundColor = .red
        videoPlaybackView.addSubview(goBack)
        goBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGoBackTap(tapGesture:))))
        
        
        
        playerLayer.videoGravity = .resizeAspectFill
        videoPlaybackPlayer.play()
        
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object:   videoPlaybackPlayer.currentItem, queue: .main) { [weak self] _ in
            videoPlaybackPlayer.seek(to: CMTime.zero)
            videoPlaybackPlayer.play()
        }
    }
    
    func hideTabBarView(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.tabBarController?.tabBar.frame = CGRect(x:(self.tabBarController?.tabBar.frame.minX)!, y:(self.tabBarController?.tabBar.frame.minY)! + 100, width:(self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
        }, completion: { finished in
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(animated){
            hideTabBarView()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        //STOP PLAYING audio/video
    }
    
    func createComposition(){
        let assets = recordingUrlList.map{AVURLAsset(url: $0)}
        let composition = AVMutableComposition()
        
        for asset in assets{
            guard
                let compositionTrack = composition.addMutableTrack(
                    withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                let assetTrack = asset.tracks(withMediaType: .video).first
                else {
                    print("Something is wrong with the asset.")
                    //                onComplete(nil)
                    return
            }
            
            
            do {
                // 1
                let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
                // 2
                try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
                
                // 3
                if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
                    let compositionAudioTrack = composition.addMutableTrack(
                        withMediaType: .audio,
                        preferredTrackID: kCMPersistentTrackID_Invalid) {
                    try compositionAudioTrack.insertTimeRange(
                        timeRange,
                        of: audioAssetTrack,
                        at: .zero)
                }
            } catch {
                // 4
                print(error)
                //            onComplete(nil)
                return
            }
            
            
            
        }
//        compositionTrack.preferredTransform = assetTrack.preferredTransform
//        let videoInfo = orientation(from: assetTrack.preferredTransform)
//
//        let videoSize: CGSize
//        if videoInfo.isPortrait {
//            videoSize = CGSize(
//                width: assetTrack.naturalSize.height,
//                height: assetTrack.naturalSize.width)
//        } else {
//            videoSize = assetTrack.naturalSize
//        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        displayRecordedVideos()
        
//        createComposition()
        let goBack = UIView(frame: CGRect(x: 50, y: 50, width: 70, height: 70))
        goBack.backgroundColor = .red
        self.view.addSubview(goBack)
        self.view.backgroundColor = .white
        goBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGoBackTap(tapGesture:))))

    }
    
    
    @objc func handleGoBackTap(tapGesture: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
}

