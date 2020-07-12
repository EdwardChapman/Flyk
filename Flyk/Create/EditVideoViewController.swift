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


class MenuTargetView : UIView{
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
        myTargetView.isUserInteractionEnabled = true
        myTargetView.becomeFirstResponder()
        MenuTargetView.shared.isHidden = true
        
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



class EditVideoViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    let videoPlaybackView = UIView()
    let videoPlaybackPlayer = AVPlayer()
    
    let basketContainer = UIView()
    
    var returnToForegroundObserver : NSObjectProtocol?
    
    
    var videoOverlayView = UIView()
    
    var videoDidEndObserver: NSObjectProtocol?
    
    var visibilityDurationStartTime = [UIView: Double]()
//    visibilityDurationStartTime[self.view] = 5
    var visibilityDurationEndTime = [UIView: Double]()
    
    
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
    
    func setupButtons(){
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
        self.view.addSubview(videoOverlayView)
        videoOverlayView.translatesAutoresizingMaskIntoConstraints = false
        videoOverlayView.leadingAnchor.constraint(equalTo: videoPlaybackView.leadingAnchor).isActive = true
        videoOverlayView.trailingAnchor.constraint(equalTo: videoPlaybackView.trailingAnchor).isActive = true
        videoOverlayView.topAnchor.constraint(equalTo: videoPlaybackView.topAnchor).isActive = true
        videoOverlayView.bottomAnchor.constraint(equalTo: videoPlaybackView.bottomAnchor).isActive = true
        videoOverlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTextViewTap(tapGesture:))))
        videoOverlayView.addGestureRecognizer(InitialPanGestureRecognizer(target: self, action: #selector(self.handleBasketItemPan(panGesture:))))
        videoOverlayView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.handleBasketItemPinch(pinchGesture:))))
        videoOverlayView.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(self.handleBasketItemRotation(rotationGesture:))))
        for ges in videoOverlayView.gestureRecognizers!{
            ges.delegate = self
        }
        
        setupButtons()
        
        
        let goBack = UIImageView(image: UIImage(named: "X"))
        goBack.layer.opacity = 0.6
        goBack.frame = CGRect(x: 20, y: 40, width: 30, height: 30)
        goBack.contentMode = .scaleAspectFit
        goBack.isUserInteractionEnabled = true
        self.view.addSubview(goBack)
        //        self.view.backgroundColor = .white
        goBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGoBackTap(tapGesture:))))
     
        
        self.view.addSubview(MenuTargetView.shared)
        
    }
    
    @objc func handleTextViewTap(tapGesture: UITapGestureRecognizer) {
        print("BEGINNING")
        let loc = tapGesture.location(in: tapGesture.view)
        let targetView = tapGesture.view?.presentationHitTest(pointLoc: loc, withinDepth: 1)
        if(targetView === videoOverlayView){return}
        
        
//        targetView?.window?.makeKeyAndVisible()
        MenuTargetView.shared.myTargetView = targetView
    
        UIMenuController.shared.menuItems = [
            UIMenuItem(title: "Timing", action: #selector(MenuTargetView.shared.changeMyTargetViewDuration)),
            UIMenuItem(title: "Edit", action: #selector(MenuTargetView.shared.editMyTargetView))
        ]
        MenuTargetView.shared.becomeFirstResponder()
        
        UIMenuController.shared.setMenuVisible(true, animated: true)
        
        
        
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
            

            let textview = UITextField()
            textview.layer.opacity = 1
            textview.backgroundColor = .red
            textview.text = "TEXT"
            textview.font = textview.font!.withSize(50)
            textview.textColor = .white
            textview.becomeFirstResponder()
            videoOverlayView.addSubview(textview)
            print(textview.gestureRecognizers)
            textview.frame = CGRect(origin: CGPoint(x: 0, y: 300), size: textview.attributedText!.size())
            textview.center.x = videoOverlayView.center.x
            
            textview.delegate = self
            
            
            visibilityDurationStartTime[textview] = 1
            visibilityDurationEndTime[textview] = 3
            
//            textview.isUserInteractionEnabled = true
            
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        textField.isUserInteractionEnabled = true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason){
        textField.isUserInteractionEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        print("HI")
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        textField.text = updatedString
        var newSize = textField.attributedText!.size()
        print(updatedString?.count)
        if updatedString?.count == 0 {
            newSize.width = 4
            newSize.height = textField.frame.height
        }
        
        textField.frame = CGRect(origin: textField.frame.origin, size: newSize)
        return false
    }
    


    
    var initialCenter :CGPoint!
    var panGestureTargetView : UIView!
    @objc func handleBasketItemPan(panGesture: InitialPanGestureRecognizer) {
//        let loc = panGesture.location(in: panGesture.view)
      
        if panGesture.state == .began {
//            panGesture.isEnabled = false
//            panGesture.isEnabled = true
            // Save the view's original position.
            panGestureTargetView = panGesture.view?.presentationHitTest(pointLoc: panGesture.location(in: panGesture.view), withinDepth: 1)
            self.initialCenter = panGestureTargetView?.center
        }
        
        if(panGestureTargetView === videoOverlayView){return}
        let translation = panGesture.translation(in: panGestureTargetView?.superview)
        // Update the position for the .began, .changed, and .ended states
        if panGesture.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            panGestureTargetView?.center = newCenter
        }
        else {
            // On cancellation, return the piece to its original location.
            panGestureTargetView?.center = initialCenter
        }
    }
    
    var pinchGestureTargetView : UIView!
    @objc func handleBasketItemPinch(pinchGesture: UIPinchGestureRecognizer){

        if pinchGesture.state == .began {
            let loc = pinchGesture.location(in: pinchGesture.view)
            pinchGestureTargetView = pinchGesture.view?.presentationHitTest(pointLoc: loc, withinDepth: 1)
            
        }
        if(pinchGestureTargetView === videoOverlayView){return}
        
        if pinchGesture.state == .began || pinchGesture.state == .changed {
            pinchGestureTargetView!.transform = (pinchGestureTargetView!.transform.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale))
            pinchGesture.scale = 1.0
        }
    }
    
    var rotationGestureTargetView : UIView!
    @objc func handleBasketItemRotation(rotationGesture: UIRotationGestureRecognizer){
        
        if rotationGesture.state == .began {
            let loc = rotationGesture.location(in: rotationGesture.view)
            rotationGestureTargetView = rotationGesture.view?.presentationHitTest(pointLoc: loc, withinDepth: 1)
        }
        
        if(rotationGestureTargetView === videoOverlayView){return}
        
        if rotationGesture.state == .changed {
            rotationGestureTargetView!.transform = rotationGestureTargetView!.transform.rotated(by: rotationGesture.rotation)
            rotationGesture.rotation = 0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            // If the gesture recognizers are on diferent views, do not allow
            // simultaneous recognition.
            if gestureRecognizer.view !== otherGestureRecognizer.view {
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

