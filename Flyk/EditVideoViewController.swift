//
//  ThirdViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation

import UIKit.UIGestureRecognizerSubclass

class InitialPanGestureRecognizer: UIPanGestureRecognizer {
    var initialTouchLocation: CGPoint!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        initialTouchLocation = touches.first!.location(in: view?.superview)
    }
}




class EditVideoViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let videoPlaybackView = UIView()
    let videoPlaybackPlayer = AVPlayer()
    
    let basketContainer = UIView()
    
    var returnToForegroundObserver : NSObjectProtocol?
    
    var overlayedElements: [UIView] = []
    
    
    
    var basketContainerIsHidden = true {
        didSet{
            var newBasketContainerY = self.view.frame.maxY - self.basketContainer.frame.height
            if(basketContainerIsHidden){ newBasketContainerY = self.view.frame.maxY }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.basketContainer.frame = CGRect(x: self.basketContainer.frame.minX, y: newBasketContainerY, width: self.basketContainer.frame.width, height: self.basketContainer.frame.width)
            }, completion: { finished in
                
            })
        }
    }
    
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
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object:   videoPlaybackPlayer.currentItem, queue: .main) { [weak self] _ in
            self?.videoPlaybackPlayer.seek(to: CMTime.zero)
            
            print(Thread.current)
            
            UIView.animateKeyframes(withDuration: (self!.videoPlaybackPlayer.currentItem?.duration.seconds)!, delay: 0, options: .allowUserInteraction, animations: {
                
                for element in self!.overlayedElements{
                    UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0, animations: {
                        element.alpha = 1
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0, animations: {
                        element.alpha = 0.011
                    })
                }
            }, completion: { finished in
//                overlayedElements[0].vis
            })
            print(self!.overlayedElements[0].layer.animationKeys())
            self?.videoPlaybackPlayer.play()
        }
        
        
        returnToForegroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            self.videoPlaybackPlayer.play()
            // do whatever you want when the app is brought back to the foreground
        }
    
    }
    
    deinit {
        if let returnToForegroundObserver = returnToForegroundObserver {
            NotificationCenter.default.removeObserver(returnToForegroundObserver)
        }
    }
    
    

    
    func createComposition(){
        
//        print("COMPOSITION IS BEING CREATED")
        
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
    
    
    func setupBasket(){
        
        let basket = UIImageView(image: UIImage(named: "basketV2"))
        basket.frame = CGRect(x: 25, y: self.view.frame.maxY - 80, width: 50, height: 50)
        basket.contentMode = .scaleAspectFit
        basket.isUserInteractionEnabled = true
        self.view.addSubview(basket)
        basket.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBasketTap(tapGesture:))))
        
        basketContainer.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        basketContainer.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.width)
        basketContainer.layer.cornerRadius = 38
        self.view.addSubview(basketContainer)
        
        let addText = UIImageView(image: UIImage(named: "T"))
        addText.layer.name = "addText"
        addText.frame = CGRect(x: 20, y: 20, width: 50, height: 50)
        addText.contentMode = .scaleAspectFit
        addText.isUserInteractionEnabled = true
        addText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBasketItemTap(tapGesture:))))
        basketContainer.addSubview(addText)
    }
    
    func setupOverlay(){
        setupBasket()
        
        
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
        setupOverlay()
        
        
        let goBack = UIImageView(image: UIImage(named: "X"))
        goBack.layer.opacity = 0.6
        goBack.frame = CGRect(x: 20, y: 40, width: 30, height: 30)
        goBack.contentMode = .scaleAspectFit
        goBack.isUserInteractionEnabled = true
        self.view.addSubview(goBack)
        //        self.view.backgroundColor = .white
        goBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGoBackTap(tapGesture:))))
        

        

        
        
//        UIView.animate(withDuration: 0, delay: 2, options: .curveEaseOut, animations: {
//            textview.layer.opacity = 1
//        }, completion: { finished in
//            print(textview.layer.animationKeys())
//        })
//
////        let startVisible = CABasicAnimation(keyPath:"opacity")
////        startVisible.duration = 0.001    // for fade in duration
////        startVisible.repeatCount = 1
////        startVisible.fromValue = 0.0
////        startVisible.toValue = 1.0
////        startVisible.beginTime = CACurrentMediaTime() + 1 // overlay time range start duration
////        startVisible.isRemovedOnCompletion = false
////        startVisible.fillMode = CAMediaTimingFillMode.forwards
////        textview.layer.add(startVisible, forKey: "startAnimation")
//
//        let endVisible = CABasicAnimation.init(keyPath:"opacity")
//        endVisible.duration = 0.001
//        endVisible.repeatCount = 1
//        endVisible.fromValue = 1.0
//        endVisible.toValue = 0.0
//        endVisible.beginTime = CACurrentMediaTime() + 4
//        endVisible.fillMode = CAMediaTimingFillMode.forwards
//        endVisible.isRemovedOnCompletion = false
//        textview.layer.add(endVisible, forKey: "endAnimation")
//
//        print(textview.layer.animationKeys())
//        textview.layer.add(textview.layer.animation(forKey: "opacity")!, forKey: "startAnimation")

        
        
        

//        print(self.view.layer.timeOffset)
//        self.view.layer.beginTime = 0
//        print(self.view.layer.timeOffset)


    }
    
    @objc func handleTextViewTap(tapGesture: UITapGestureRecognizer) {
        print("tapGesture.view!.laye")
    
    }
    
    @objc func handleGoBackTap(tapGesture: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc func handleBasketTap(tapGesture: UITapGestureRecognizer) {
        basketContainerIsHidden = false
    }
    
    @objc func handleBasketItemTap(tapGesture: UITapGestureRecognizer) {
        basketContainerIsHidden = true
        
        
        // ACTUALLY THIS SHOULD JUST COPY THE VIEW IT IS PASSED........
        // IN THE CASE OF TEXT IT SHOULD BE A UITEXTVIEW? OR CATEXTLAYER
        if(tapGesture.view!.layer.name == "addText"){
            
            let textview = UILabel()
            textview.layer.opacity = 1
            textview.backgroundColor = .red
            textview.text = "TEXT"
            textview.font = textview.font.withSize(50)
            textview.textColor = .white
            self.view.addSubview(textview)
            
            textview.frame = CGRect(origin: CGPoint(x: 0, y: 500), size: textview.attributedText!.size())
            
            overlayedElements.append(textview)
            
            
            textview.isUserInteractionEnabled = true
            textview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTextViewTap(tapGesture:))))

            textview.addGestureRecognizer(InitialPanGestureRecognizer(target: self, action: #selector(self.handleBasketItemPan(panGesture:))))

            textview.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.handleBasketItemPinch(pinchGesture:))))

            textview.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(self.handleBasketItemRotation(rotationGesture:))))
            
            for ges in textview.gestureRecognizers!{
                ges.delegate = self
            }
            
        }
        
    }
    

    
    
    var initialCenter :CGPoint!
    @objc func handleBasketItemPan(panGesture: InitialPanGestureRecognizer) {
        let item = panGesture.view
        let translation = panGesture.translation(in: item?.superview)
        if panGesture.state == .began {
            // Save the view's original position.
            self.initialCenter = item?.center
        }
        // Update the position for the .began, .changed, and .ended states
        if panGesture.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            item!.center = newCenter
        }
        else {
            // On cancellation, return the piece to its original location.
            item!.center = initialCenter
        }
    }
    
    @objc func handleBasketItemPinch(pinchGesture: UIPinchGestureRecognizer){
        print("PINCH", pinchGesture.scale)
        if pinchGesture.state == .began || pinchGesture.state == .changed {
            pinchGesture.view?.transform = (pinchGesture.view?.transform.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale))!
            pinchGesture.scale = 1.0
        }
    }
    
    @objc func handleBasketItemRotation(rotationGesture: UIRotationGestureRecognizer){
        guard rotationGesture.view != nil else { return }
        
        if rotationGesture.state == .began || rotationGesture.state == .changed {
            rotationGesture.view?.transform = rotationGesture.view!.transform.rotated(by: rotationGesture.rotation)
            rotationGesture.rotation = 0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
//            // If the gesture recognizer's view isn't one of the squares, do not
//            // allow simultaneous recognition.
//            if gestureRecognizer.view != self.yellowView &&
//                gestureRecognizer.view != self.cyanView &&
//                gestureRecognizer.view != self.magentaView {
//                return false
//            }
            // If the gesture recognizers are on diferent views, do not allow
            // simultaneous recognition.
            if gestureRecognizer.view != otherGestureRecognizer.view {
                return false
            }
            // If either gesture recognizer is a long press, do not allow
            // simultaneous recognition.
            if gestureRecognizer is UILongPressGestureRecognizer ||
                otherGestureRecognizer is UILongPressGestureRecognizer {
                return false
            }
            
            return true
    }

}

