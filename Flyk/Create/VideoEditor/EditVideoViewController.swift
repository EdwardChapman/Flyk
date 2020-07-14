//
//  ThirdViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation


class TriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
     
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY/2))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.closePath()
        
        context.setFillColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1)

        context.fillPath()
    }
}


class EditVideoViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var recordingUrlList : [URL] = []
    let videoPlaybackView = UIView()
    let videoPlaybackPlayer = AVPlayer()
    
    var basketContainer : BasketView?
    var videoOverlayView = VideoOverlayView()
    let textEditorView = TextEditor()
    
    var visibilityDurationStartTime = [UIView: Double]()
    var visibilityDurationEndTime = [UIView: Double]()
    
    var UrlRecordingStartTimes = [UIView: Double]()
    var UrlRecordingEndTimes = [UIView: Double]()
    
    var returnToForegroundObserver : NSObjectProtocol?
    var videoDidEndObserver: NSObjectProtocol?
    
    var currentDurationEditTarget: UIView?
    
    
    lazy var setDurationView : SetDurationView = {
        let durationView = SetDurationView(frame: CGRect(x: self.view.frame.minX, y: self.view.frame.maxY, width: self.view.frame.width, height: 200))
        self.view.addSubview(durationView)
        
        durationView.rightTabDragger.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handleRightDraggerPan(panGesture:))))
        
        durationView.leftTabDragger.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handleLeftDraggerPan(panGesture:))))
        
        durationView.timeCursor.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handleCursorPan(panGesture:))))
        return durationView
    }()
    
    @objc func handleCursorPan(panGesture: UIPanGestureRecognizer){
        if panGesture.state == .began{
            self.videoPlaybackPlayer.pause()
        }else if panGesture.state == .ended {
            self.videoPlaybackPlayer.play()
        }
        let trans = panGesture.translation(in: setDurationView.thumbnailView).x
        let panPercentage = trans/setDurationView.thumbnailView.frame.width
        let seekDif = Double(panPercentage) * (self.videoPlaybackPlayer.currentItem?.duration.seconds)!
        
        let seekTime = seekDif+((self.videoPlaybackPlayer.currentItem?.currentTime().seconds)!)
//        print(trans, seekTime)
        setDurationView.currentPlayPercentage = seekTime / (self.videoPlaybackPlayer.currentItem?.duration.seconds)!
        self.videoPlaybackPlayer.seek(to: CMTime(seconds: seekTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceBefore: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceAfter: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        
        panGesture.setTranslation(CGPoint(x: 0,y: 0), in: setDurationView.thumbnailView)
    }
    
    
    @objc func handleLeftDraggerPan(panGesture: UIPanGestureRecognizer){
        
        if panGesture.state == .began{
            self.videoPlaybackPlayer.pause()
        }else if panGesture.state == .ended {
            self.videoPlaybackPlayer.play()
        }
        
        let trans = panGesture.translation(in: setDurationView.thumbnailView).x
        let per = trans/setDurationView.thumbnailView.frame.width
        setDurationView.leftDragPercentage += per
        
        panGesture.setTranslation(CGPoint(x: 0,y: 0), in: setDurationView.leftTabDragger.superview!)
        
        self.videoPlaybackPlayer.seek(to: CMTime(seconds: (self.videoPlaybackPlayer.currentItem?.duration.seconds)! * Double(setDurationView.leftDragPercentage), preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceBefore: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceAfter: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        
        if let currentDurationEditTarget = self.currentDurationEditTarget {
            self.visibilityDurationStartTime[currentDurationEditTarget] = Double(self.setDurationView.leftDragPercentage) * (self.videoPlaybackPlayer.currentItem?.duration.seconds)!
        }
    
    }
    
    
    @objc func handleRightDraggerPan(panGesture: UIPanGestureRecognizer){
        if panGesture.state == .began{
            self.videoPlaybackPlayer.pause()
        }else if panGesture.state == .ended {
            self.videoPlaybackPlayer.play()
        }
        
        let trans = panGesture.translation(in: setDurationView.thumbnailView).x
        let per = trans/setDurationView.thumbnailView.frame.width
        setDurationView.rightDragPercentage += per
        
        
        panGesture.setTranslation(CGPoint(x: 0,y: 0), in: panGesture.view?.superview)
        
        self.videoPlaybackPlayer.seek(to: CMTime(seconds: (self.videoPlaybackPlayer.currentItem?.duration.seconds)! * Double(setDurationView.rightDragPercentage), preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceBefore: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceAfter: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        
        
        if let currentDurationEditTarget = self.currentDurationEditTarget {
            self.visibilityDurationEndTime[currentDurationEditTarget] = Double(self.setDurationView.rightDragPercentage) * (self.videoPlaybackPlayer.currentItem?.duration.seconds)!
        }
    }
    
    
    
    var timeObserverToken: Any?
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.03, preferredTimescale: timeScale)
        
        timeObserverToken = videoPlaybackPlayer.addPeriodicTimeObserver(forInterval: time, queue: .main)
        { [weak self] time in
            // update player transport UI
            
            if let currentDurationEditTarget = self?.currentDurationEditTarget{
                self!.setDurationView.currentPlayPercentage = time.seconds / (self?.videoPlaybackPlayer.currentItem?.duration.seconds)!
            }
            
            for element in self!.videoOverlayView.subviews{
                if MenuTargetView.shared.myTargetView === element
                && !MenuTargetView.shared.isHidden{
                    element.isHidden = false
                }else{
                    if let elementStartTime = self!.visibilityDurationStartTime[element], let elementEndTime = self!.visibilityDurationEndTime[element] {
                        if time.seconds >= elementStartTime && time.seconds <= elementEndTime {
                            element.isHidden = false
                        } else {
                            element.isHidden = true
                        }
                    }else if let elementStartTime = self!.visibilityDurationStartTime[element] {
                        if time.seconds >= elementStartTime {
                            element.isHidden = false
                        }else{
                            element.isHidden = true
                        }
                    }else if let elementEndTime = self!.visibilityDurationEndTime[element] {
                        if time.seconds <= elementEndTime {
                            element.isHidden = false
                        }else{
                            element.isHidden = true
                        }
                    } else {
                        element.isHidden = false
                    }
                }
            }
            
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            videoPlaybackPlayer.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    func setupPlaybackView(){
        
        let playerLayer = AVPlayerLayer(player: videoPlaybackPlayer)
        //        playerLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
//        self.view.layer.addSublayer(playerLayer)
        
        self.view.addSubview(videoPlaybackView)
        videoPlaybackView.layer.addSublayer(playerLayer)
        videoPlaybackView.frame = self.view.frame
//        videoPlaybackView.translatesAutoresizingMaskIntoConstraints = false
//        videoPlaybackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        videoPlaybackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        videoPlaybackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//        videoPlaybackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//                videoPlaybackView.heightAnchor.constraint(equalToConstant: self.view.frame.height + (self.tabBarController?.tabBar.frame.height)!).isActive = true
//        updateViewConstraints()
        self.view.layoutSubviews()
        
        playerLayer.frame = CGRect(x: 0, y: 0, width: videoPlaybackView.frame.width, height: videoPlaybackView.frame.height)
        
        
        playerLayer.videoGravity = .resizeAspectFill
        videoPlaybackPlayer.play()
        
        videoDidEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object:   videoPlaybackPlayer.currentItem, queue: .main) { [weak self] _ in
            self?.videoPlaybackPlayer.seek(to: CMTime.zero)
            
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
        removePeriodicTimeObserver()
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
    
    @objc func handleGoBackTap(tapGesture: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // ViewDidLoad ////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        super.viewDidLoad()
        setupPlaybackView()
        createComposition()
        
        
        self.view.addSubview(videoOverlayView)
        videoOverlayView.frame = self.view.frame
//        videoOverlayView.translatesAutoresizingMaskIntoConstraints = false
//        videoOverlayView.leadingAnchor.constraint(equalTo: videoPlaybackView.leadingAnchor).isActive = true
//        videoOverlayView.trailingAnchor.constraint(equalTo: videoPlaybackView.trailingAnchor).isActive = true
//        videoOverlayView.topAnchor.constraint(equalTo: videoPlaybackView.topAnchor).isActive = true
//        videoOverlayView.bottomAnchor.constraint(equalTo: videoPlaybackView.bottomAnchor).isActive = true

        
        basketContainer = BasketView(superview: self.view)
        self.view.addSubview(basketContainer!)
        self.view.addSubview((basketContainer?.getBasketButton())!)
        for bskItem in (basketContainer?.getBasketItems())! {
            bskItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBasketItemTap(tapGesture:))))
            basketContainer?.addSubview(bskItem)
        }
        
        
        
        let goBack = UIImageView(image: UIImage(named: "X"))
        goBack.layer.opacity = 0.6
        goBack.frame = CGRect(x: 20, y: 40, width: 30, height: 30)
        goBack.contentMode = .scaleAspectFit
        goBack.isUserInteractionEnabled = true
        self.view.addSubview(goBack)
        //        self.view.backgroundColor = .white
        goBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGoBackTap(tapGesture:))))
     
        
        self.view.addSubview(MenuTargetView.shared)
        MenuTargetView.shared.viewController = self
        MenuTargetView.shared.isHidden = true
        
        
        
        
        self.view.addSubview(textEditorView)
        textEditorView.frame = self.view.bounds
        
        
        
        
        
        videoOverlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTextViewTap(tapGesture:))))
        
        
        addPeriodicTimeObserver()
        
        
        let triView = TriangleView(frame: CGRect(x: self.view.frame.maxX - 80, y: self.view.frame.maxY - 80, width: 45, height: 35))
        self.view.addSubview(triView)
    }
    
    
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    
    @objc func handleBasketItemTap(tapGesture: UITapGestureRecognizer) {
        basketContainer!.isHidden = true
        if(tapGesture.view!.layer.name == "addText"){
            let textField = basketContainer!.createTextField()
            textField.center.x = self.videoOverlayView.center.x
            self.videoOverlayView.addSubview(textField)
            textField.delegate = self.textEditorView
            self.textEditorView.beginEditing(textField: textField)
        }
        
    }

    
    
    @objc func handleTextViewTap(tapGesture: UITapGestureRecognizer) {
        if !basketContainer!.isHidden {basketContainer?.isHidden = true}
        let loc = tapGesture.location(in: tapGesture.view)
        let targetView = tapGesture.view?.presentationHitTest(pointLoc: loc, withinDepth: 1)
        if(targetView === self.videoOverlayView){return}
        
        if let oldDurationEditTarget = self.currentDurationEditTarget{
            self.currentDurationEditTarget = targetView
            setDurationView.replaceBothPercentValuesWithValidNumbers(
                left: CGFloat(visibilityDurationStartTime[self.currentDurationEditTarget!] ?? 0),
                right: CGFloat(visibilityDurationEndTime[self.currentDurationEditTarget!] ?? 1)
            )
            
            if let visStartTime = visibilityDurationStartTime[self.currentDurationEditTarget!] {
                setDurationView.replaceLeftPercentWithValidNumber(
                    left: CGFloat(visStartTime/(self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
                )
            }else{
                setDurationView.replaceLeftPercentWithValidNumber(
                    left: 0
                )
            }
            if let visEndTime = visibilityDurationEndTime[self.currentDurationEditTarget!] {
                setDurationView.replaceRightPercentWithValidNumber(
                    right: CGFloat(visEndTime/(self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
                )
            }else{
                setDurationView.replaceRightPercentWithValidNumber(
                    right: 1
                )
            }
            setDurationView.updateLeftSlider()
            setDurationView.updateRightSlider()
            
            
        }else{
            MenuTargetView.shared.myTargetView = targetView
            UIMenuController.shared.menuItems = [
                UIMenuItem(title: "Timing", action: #selector(self.changeMyTargetViewDuration)),
                UIMenuItem(title: "Edit", action: #selector(self.editMyTargetView)),
                UIMenuItem(title: "🗑", action: #selector(deleteMyTargetView))
            ]
            
            if MenuTargetView.shared.becomeFirstResponder() {
                UIMenuController.shared.setMenuVisible(true, animated: true)
            }
        }
    }
    
    @objc func changeMyTargetViewDuration(){
        print("CHANGE MY TARGETVIEW DURATINO")
        MenuTargetView.shared.isHidden = true
        currentDurationEditTarget = MenuTargetView.shared.myTargetView
        if let visibilityStart = visibilityDurationStartTime[currentDurationEditTarget!] {
            setDurationView.leftDragPercentage = CGFloat(visibilityStart / (self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
        }
        if let visibilityEnd = visibilityDurationEndTime[currentDurationEditTarget!] {
            setDurationView.leftDragPercentage = CGFloat(visibilityEnd / (self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
        }
        activateSetDuration()
        
    }
    @objc func editMyTargetView(){
        MenuTargetView.shared.isHidden = true
        textEditorView.beginEditing(textField: MenuTargetView.shared.myTargetView as! UITextField)
    }
    @objc func deleteMyTargetView(){
        MenuTargetView.shared.isHidden = true
        MenuTargetView.shared.myTargetView.removeFromSuperview()
    }
    
    

    
    func activateSetDuration(){
        if self.videoPlaybackView.transform == CGAffineTransform.identity {
            
            self.videoPlaybackView.layer.anchorPoint = CGPoint(x: 0.5,y: 0)
            self.videoPlaybackView.layer.position = CGPoint(x: self.videoPlaybackView.frame.midX, y: 0)
            
            self.videoOverlayView.layer.anchorPoint = CGPoint(x: 0.5,y: 0)
            self.videoOverlayView.layer.position = CGPoint(x: self.videoOverlayView.frame.midX, y: 0)
            
            let xScaleFactor : CGFloat = (self.videoPlaybackView.frame.height - self.view.safeAreaInsets.top - self.setDurationView.frame.height)/self.videoPlaybackView.frame.height
            let yScaleFactor: CGFloat = xScaleFactor
            
            setDurationView.isHidden = false
            setDurationView.activate(player: self.videoPlaybackPlayer)
            UIView.animate(withDuration: 0.3) {
                
                let fr = self.videoPlaybackView.frame
                let topCenter = CGPoint(x: fr.midX, y: self.view.safeAreaInsets.top)
//                self.videoPlaybackView.layer.anchorPoint = CGPoint(x: 0.5,y: 0)
                self.videoPlaybackView.layer.position = topCenter
                self.videoPlaybackView.transform =  self.videoPlaybackView.transform.scaledBy(x: xScaleFactor, y: yScaleFactor)
                
                let oFr = self.videoOverlayView.frame
                let oTopCenter = CGPoint(x: oFr.midX, y:  self.view.safeAreaInsets.top)
//                self.videoOverlayView.layer.anchorPoint = CGPoint(x: 0.5,y: 0)
                self.videoOverlayView.layer.position = oTopCenter
                self.videoOverlayView.transform =  self.videoOverlayView.transform.scaledBy(x: xScaleFactor, y: yScaleFactor)
                
            }
        }else{
            setDurationView.isHidden = true
            UIView.animate(withDuration: 0.3, animations: {
                let vpvFr = self.videoPlaybackView.frame
                self.videoPlaybackView.transform = CGAffineTransform.identity
                self.videoPlaybackView.layer.position = CGPoint(x: vpvFr.midX, y: 0)
                
                
                let vovFr = self.videoPlaybackView.frame
                self.videoOverlayView.transform = CGAffineTransform.identity
                self.videoOverlayView.layer.position = CGPoint(x: vovFr.midX, y: 0)
                
                
                
            }, completion: { finished in
                self.setDurationView.deactivate()
                
            })

        }
    }

    
}

