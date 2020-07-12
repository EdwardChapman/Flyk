//
//  ThirdViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation



class MenuTargetView : UIView {
    static let shared = MenuTargetView()
    var myTargetView: UIView! {
        didSet{
            MenuTargetView.shared.frame = myTargetView.frame
            UIMenuController.shared.setTargetRect(myTargetView.frame, in: myTargetView.superview!)
            MenuTargetView.shared.isHidden = false
        }
    }
    
    private init() {
        super.init(frame: CGRect())
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    @objc func menuWasDismissed(){
        self.isHidden = true
    }
    
    override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(menuWasDismissed),
                name: UIMenuController.didHideMenuNotification,
                object: nil)
            return true
        }else{
            return false
        }
    }
    override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            NotificationCenter.default.removeObserver(self, name: UIMenuController.didHideMenuNotification, object: nil)
            return true
        }else{
            return false
        }
    }
    
    @objc func changeMyTargetViewDuration(){
        print("CHANGE MY TARGETVIEW DURATINO")
        MenuTargetView.shared.isHidden = true
    }
    @objc func editMyTargetView(){
//        shared.resignFirstResponder()
//        myTargetView.isUserInteractionEnabled = true
//        myTargetView.becomeFirstResponder()
//        MenuTargetView.shared.isHidden = true
        TextEditor.view?.beginEditing(textField: myTargetView as! UITextField)
        
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let origInteractionValue = myTargetView.isUserInteractionEnabled
        myTargetView.isUserInteractionEnabled = true
        if action == #selector(changeMyTargetViewDuration) {
            myTargetView.isUserInteractionEnabled = origInteractionValue
            return true
        }else if action == #selector(editMyTargetView) && myTargetView.canBecomeFirstResponder {
            myTargetView.isUserInteractionEnabled = origInteractionValue
            return true
        }
        myTargetView.isUserInteractionEnabled = origInteractionValue
        return false
    }
}

extension UIView {
    func presentationHitTest(pointLoc: CGPoint, withinDepth: Int) -> UIView? {
        if withinDepth == 0 && self.point(inside: pointLoc, with: nil) { return self }
        for subView in self.subviews.reversed() {
            if subView.layer.presentation()!.opacity > Float(0.1){
                let convertedPoint = self.convert(pointLoc, to: subView)
                if subView.point(inside: convertedPoint, with: nil) {
                    return subView.presentationHitTest(pointLoc: convertedPoint, withinDepth: withinDepth-1)
                }
            }
        }
        if self.point(inside: pointLoc, with: nil) {
            return self
        }else{
            return nil
        }
    }
}



class EditVideoViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let videoPlaybackView = UIView()
    let videoPlaybackPlayer = AVPlayer()
    
    var basketContainer : UIView?
    
    var returnToForegroundObserver : NSObjectProtocol?
    
    
    var videoOverlayView = VideoOverlayView()
    
    var videoDidEndObserver: NSObjectProtocol?
    
    var visibilityDurationStartTime = [UIView: Double]()
//    visibilityDurationStartTime[self.view] = 5
    var visibilityDurationEndTime = [UIView: Double]()
    
    let textEditorView = TextEditor()

    
    var recordingUrlList : [URL] = [] {
        didSet{
//            createComposition()
        }
    }
    
    
  
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
    
    deinit {
        if let returnToForegroundObserver = returnToForegroundObserver {
            NotificationCenter.default.removeObserver(returnToForegroundObserver)
        }
        if let videoDidEndObserver = videoDidEndObserver {
            NotificationCenter.default.removeObserver(videoDidEndObserver)
        }
    }
    
    

    
    func createComposition(){

        let assets = recordingUrlList.map{ a -> AVURLAsset in AVURLAsset(url: a)}
        let composition = AVMutableComposition()
        
        var trackStartTime = CMTime.zero
        guard
            let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        else
            {return print("GAURD FAIL")}
        for asset in assets{
            
            guard
                let assetTrack = asset.tracks(withMediaType: .video).first
            else {
                print("Something is wrong with the asset.")
                return
            }
            
            
            do {
                // 1
                let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
                // 2
                try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: trackStartTime)
                
                // 3
                if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
                    let compositionAudioTrack = composition.addMutableTrack(
                        withMediaType: .audio,
                        preferredTrackID: kCMPersistentTrackID_Invalid) {
                    try compositionAudioTrack.insertTimeRange(timeRange, of: audioAssetTrack, at: trackStartTime)
                }
                trackStartTime = CMTimeAdd(trackStartTime, asset.duration)
            } catch {
                // 4
                print(error)
                return
            }
            
            
            compositionTrack.preferredTransform = assetTrack.preferredTransform
            let videoSize = CGSize(width: assetTrack.naturalSize.height, height: assetTrack.naturalSize.width)
            
        }
        
        
        videoPlaybackPlayer.replaceCurrentItem(with: AVPlayerItem(asset: composition))
//        let videoPlaybackPlayer = AVPlayer(playerItem: AVPlayerItem(asset: composition))
        
        

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
//        print("APPEAR")
        if(animated){
            self.tabBarController!.hideTabBarView()
        }
        videoPlaybackPlayer.play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        //STOP PLAYING audio/video
        videoPlaybackPlayer.pause()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaybackView()
        createComposition()
        
        
        self.view.addSubview(videoOverlayView)
        videoOverlayView.translatesAutoresizingMaskIntoConstraints = false
        videoOverlayView.leadingAnchor.constraint(equalTo: videoPlaybackView.leadingAnchor).isActive = true
        videoOverlayView.trailingAnchor.constraint(equalTo: videoPlaybackView.trailingAnchor).isActive = true
        videoOverlayView.topAnchor.constraint(equalTo: videoPlaybackView.topAnchor).isActive = true
        videoOverlayView.bottomAnchor.constraint(equalTo: videoPlaybackView.bottomAnchor).isActive = true

        
        basketContainer = BasketView(viewController: self)
        
        
        let goBack = UIImageView(image: UIImage(named: "X"))
        goBack.layer.opacity = 0.6
        goBack.frame = CGRect(x: 20, y: 40, width: 30, height: 30)
        goBack.contentMode = .scaleAspectFit
        goBack.isUserInteractionEnabled = true
        self.view.addSubview(goBack)
        //        self.view.backgroundColor = .white
        goBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGoBackTap(tapGesture:))))
     
        
        self.view.addSubview(MenuTargetView.shared)
        MenuTargetView.shared.isHidden = true
        
        
        
        
        self.view.addSubview(textEditorView)
        textEditorView.frame = self.view.bounds
    }
    

    
    @objc func handleGoBackTap(tapGesture: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    

    

    
}

