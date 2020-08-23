//
//  ThirdViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation





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
    
    let goBack = UIImageView(image: UIImage(named: "X"))
    
    
    lazy var setDurationView : SetDurationView = {
        let durationView = SetDurationView(frame: CGRect(x: self.view.frame.minX, y: self.view.frame.maxY, width: self.view.frame.width, height: 200))
        self.view.addSubview(durationView)
        
        durationView.rightTabDragger.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handleRightDraggerPan(panGesture:))))
        
        durationView.leftTabDragger.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handleLeftDraggerPan(panGesture:))))
        
        durationView.timeCursor.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handleCursorPan(panGesture:))))
        
        durationView.doneButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setDurationViewDoneButtonTap)))
        return durationView
    }()
    @objc func setDurationViewDoneButtonTap(tapGesture: UITapGestureRecognizer){
        currentDurationEditTarget = nil
        activateSetDuration()
    }
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

        
        self.view.addSubview(videoPlaybackView)
        videoPlaybackView.layer.addSublayer(playerLayer)
        videoPlaybackView.frame = self.view.frame
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
    
    func cleanupOnClose(){
        if let returnToForegroundObserver = returnToForegroundObserver {
            NotificationCenter.default.removeObserver(returnToForegroundObserver)
        }
        if let videoDidEndObserver = videoDidEndObserver {
            NotificationCenter.default.removeObserver(videoDidEndObserver)
        }
        removePeriodicTimeObserver()
        self.videoPlaybackPlayer.pause()
//        self.videoPlaybackPlayer.replaceCurrentItem(with: nil)
    }
    
    deinit {
        print("EDIT VIDEO VIEW CONTROLLER DEINIT")
        cleanupOnClose()
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
                print("Something is wrong with the asset --> REMOVING")
                recordingUrlList.removeAll(where: { $0 == asset.url })
                continue
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
        super.viewWillAppear(animated)
//        print("APPEAR")
        if(animated){
            self.tabBarController!.hideTabBarView()
        }
        videoPlaybackPlayer.play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //STOP PLAYING audio/video
        for subview in self.view.subviews{
            
        }
        videoPlaybackPlayer.pause()
        
    }
    
    @objc func handleGoBackTap(tapGesture: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
        cleanupOnClose()
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // ViewDidLoad ////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.flykDarkGrey
        super.viewDidLoad()
        setupPlaybackView()
        createComposition()
        
        
        self.view.addSubview(videoOverlayView)
        videoOverlayView.frame = videoPlaybackView.frame
//        videoOverlayView.translatesAutoresizingMaskIntoConstraints = false
//        videoOverlayView.leadingAnchor.constraint(equalTo: videoPlaybackView.leadingAnchor).isActive = true
//        videoOverlayView.trailingAnchor.constraint(equalTo: videoPlaybackView.trailingAnchor).isActive = true
//        videoOverlayView.topAnchor.constraint(equalTo: videoPlaybackView.topAnchor).isActive = true
//        videoOverlayView.bottomAnchor.constraint(equalTo: videoPlaybackView.bottomAnchor).isActive = true

        
        basketContainer = BasketView(superview: self.view)
        self.view.addSubview(basketContainer!)
        let bsktBucket = basketContainer!.basketButton
        self.view.addSubview(bsktBucket)
        bsktBucket.translatesAutoresizingMaskIntoConstraints = false
        bsktBucket.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        bsktBucket.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        bsktBucket.widthAnchor.constraint(equalToConstant: 35).isActive = true
        bsktBucket.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        
        
        for bskItem in (basketContainer?.getBasketItems())! {
            bskItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBasketItemTap(tapGesture:))))
            basketContainer?.addSubview(bskItem)
        }
        
        
        
        
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
        

        let finishVideoEditingView = UIImageView(image: UIImage(named: "checkArrowHollow"))
        finishVideoEditingView.contentMode = .scaleAspectFill
        finishVideoEditingView.isUserInteractionEnabled = true
        self.view.addSubview(finishVideoEditingView)
        finishVideoEditingView.translatesAutoresizingMaskIntoConstraints = false
        finishVideoEditingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        finishVideoEditingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        finishVideoEditingView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        finishVideoEditingView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        
        finishVideoEditingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleFinishEditingTap(tapGesture:))))
    }

    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    
    private func compositionLayerInstruction(for track: AVAssetTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {

        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = assetTrack.preferredTransform
        
        instruction.setTransform(transform, at: .zero)
        
        return instruction
    }
    
    func createOverlayLayer(naturalVideoSize: CGSize) -> CALayer {
        let overlayLayer = CALayer()
        overlayLayer.frame = self.videoOverlayView.frame
        for subview in self.videoOverlayView.subviews {
            var newLayer: CALayer?
            if let textField = subview as? UITextField{
                let textLayer = CATextLayer()
                textLayer.string = textField.attributedText
                textLayer.shouldRasterize = true
                textLayer.rasterizationScale = UIScreen.main.scale
                textLayer.backgroundColor = textField.backgroundColor?.cgColor
                textLayer.cornerRadius = textField.layer.cornerRadius
                textLayer.alignmentMode = .center
                
                let textFieldTransform = textField.layer.transform
                textField.layer.transform = CATransform3DIdentity
                let preTransformFrame = textField.frame
                textField.layer.transform = textFieldTransform
                
                textLayer.frame = preTransformFrame
                textLayer.transform = textField.layer.transform
                textLayer.contentsScale = UIScreen.main.scale
                newLayer = textLayer
            }
            overlayLayer.isGeometryFlipped = true
            if let newLayer = newLayer {
                overlayLayer.addSublayer(newLayer)
                addAnimationToOverlay(fromView: subview, newLayer: newLayer)
            }
        }
        overlayLayer.transform = CATransform3DMakeScale(naturalVideoSize.height / self.videoOverlayView.frame.height, naturalVideoSize.height / self.videoOverlayView.frame.height, 1)
        overlayLayer.frame.origin = CGPoint(x: (naturalVideoSize.width/2)-overlayLayer.frame.width/2, y: .zero)
        return overlayLayer
    }
    
    func addAnimationToOverlay(fromView: UIView, newLayer: CALayer){
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        
        var opacityValues : [Float] = []
        var opacityKeyTimes : [NSNumber] = []
        
        if let elementStartTime = self.visibilityDurationStartTime[fromView] {
            opacityValues.append(0)
            opacityKeyTimes.append(0)
            
            opacityValues.append(0)
            opacityKeyTimes.append(
                NSNumber(value: elementStartTime/(self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
            )
            opacityValues.append(1)
            opacityKeyTimes.append(
                NSNumber(value: elementStartTime/(self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
            )
        }
        if let elementEndTime = self.visibilityDurationEndTime[fromView] {
            opacityValues.append(1)
            opacityKeyTimes.append(
                NSNumber(value: elementEndTime/(self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
            )
            opacityValues.append(0)
            opacityKeyTimes.append(
                NSNumber(value: elementEndTime/(self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
            )
        }
        
        if opacityKeyTimes.count > 0 {
            opacityAnimation.values = opacityValues
            opacityAnimation.keyTimes = opacityKeyTimes
            opacityAnimation.duration = (self.videoPlaybackPlayer.currentItem?.duration.seconds)!
            opacityAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
            opacityAnimation.isRemovedOnCompletion = false
            newLayer.add(opacityAnimation, forKey: "opacity")
        }
    }
    
    @objc func handleFinishEditingTap(tapGesture: UITapGestureRecognizer){
        
        
        let finishedVideoVC = FinishedVideoViewController()
        self.navigationController?.pushViewController(finishedVideoVC, animated: true)
        
        self.removePeriodicTimeObserver()
        self.videoPlaybackPlayer.pause()
        self.videoPlaybackPlayer.seek(to: .zero)
        
        let curVideoPlayerLength = (self.videoPlaybackPlayer.currentItem?.duration.seconds)!
        
        /*
        for element in self.videoOverlayView.subviews{
            element.isHidden = false
            element.layer.opacity = 1
            let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
            
            var opacityValues : [Float] = []
            var opacityKeyTimes : [NSNumber] = []
            
            if let elementStartTime = self.visibilityDurationStartTime[element] {
                opacityValues.append(0)
                opacityKeyTimes.append(0)
                
                opacityValues.append(0)
                opacityKeyTimes.append(
                    NSNumber(value: elementStartTime/(self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
                    )
                opacityValues.append(1)
                opacityKeyTimes.append(
                    NSNumber(value: elementStartTime/(self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
                )
            }
            if let elementEndTime = self.visibilityDurationEndTime[element] {
                opacityValues.append(1)
                opacityKeyTimes.append(
                    NSNumber(value: elementEndTime/(self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
                )
                opacityValues.append(0)
                opacityKeyTimes.append(
                    NSNumber(value: elementEndTime/(self.videoPlaybackPlayer.currentItem?.duration.seconds)!)
                )
            }
            
            if opacityKeyTimes.count > 0 {
                opacityAnimation.values = opacityValues
                opacityAnimation.keyTimes = opacityKeyTimes
                opacityAnimation.duration = (self.videoPlaybackPlayer.currentItem?.duration.seconds)!
                opacityAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
                opacityAnimation.isRemovedOnCompletion = false
                element.layer.add(opacityAnimation, forKey: "opacity")
            }
        }
 
         */
        
        var natTrackSize = self.videoPlaybackPlayer.currentItem?.asset.tracks(withMediaType: .video).first?.naturalSize
        
        if natTrackSize!.height < natTrackSize!.width {
            natTrackSize = CGSize(width: natTrackSize!.height, height: natTrackSize!.width)
        }
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: natTrackSize!)
        

        let overlayLayer = createOverlayLayer(naturalVideoSize: natTrackSize!)
        
        func swapYCoordinateOfSublayer(superlayer: CALayer){
            if let sublayers = superlayer.sublayers{
                for sublayer in sublayers{
                    let curY = sublayer.frame.minY
                    let newOrigin = CGPoint(x: sublayer.frame.minX, y: superlayer.frame.height-curY - sublayer.frame.height)
                    sublayer.frame = CGRect(origin: newOrigin, size: sublayer.frame.size)
                }
            }
        }
        

        let outputLayer = CALayer()
        outputLayer.addSublayer(videoLayer)
        outputLayer.addSublayer(overlayLayer)
        
        

        
        let finalVideoComposition = AVMutableVideoComposition()
        finalVideoComposition.renderSize = natTrackSize!
        finalVideoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        finalVideoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: outputLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(
            start: .zero,
            duration: self.videoPlaybackPlayer.currentItem!.duration)
        finalVideoComposition.instructions = [instruction]
        let videoLayerInstructions = compositionLayerInstruction(
            for: (self.videoPlaybackPlayer.currentItem?.asset.tracks(withMediaType: .video).first)!,
            assetTrack: (self.videoPlaybackPlayer.currentItem?.asset.tracks(withMediaType: .video).first)!)

        instruction.layerInstructions = [videoLayerInstructions]

        
        exportVideo(finalVideoComposition: finalVideoComposition)
    }
    

    
    func exportVideo(finalVideoComposition: AVMutableVideoComposition){
        guard let export = AVAssetExportSession(
            asset: self.videoPlaybackPlayer.currentItem!.asset,
            presetName: AVAssetExportPreset960x540)
            else {
                print("Cannot create export session.")
                return
        }
        
        let videoName = UUID().uuidString
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension("mov")
        
        export.videoComposition = finalVideoComposition
        export.outputFileType = .mov
        export.outputURL = exportURL
        
        
        export.exportAsynchronously {
            DispatchQueue.main.async {
                switch export.status {
                case .completed:
                    print("EXPORT SUCCESSFUL")
                    
                    if let finVC = self.navigationController?.topViewController as? FinishedVideoViewController {
                        finVC.finishedViewURL = exportURL
                    }
                    
                default:
                    self.navigationController?.popViewController(animated: true)
                    print("Something went wrong during export.")
                    print(export.error ?? "unknown error")
                    
                    break
                }
            }
        }
    }
    
    
    @objc func handleBasketItemTap(tapGesture: UITapGestureRecognizer) {
        basketContainer!.isHidden = true
        if(tapGesture.view!.layer.name == "addText"){
            let textField = basketContainer!.createTextField()
            textField.center.x = self.videoOverlayView.center.x
            self.videoOverlayView.addSubview(textField)
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
            self.goBack.isHidden = true
            
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
            self.goBack.isHidden = false
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

