//
//  ThirdViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation


extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}

extension NSNotification.Name {
    static let recordedDurationChanged = NSNotification.Name(Bundle.main.bundleIdentifier! + ".recordedDuration")
}



class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

class TakeVideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    func showTabBarView(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.tabBarController?.tabBar.frame = CGRect(x:(self.tabBarController?.tabBar.frame.minX)!, y:(self.tabBarController?.view.frame.maxY)! - (self.tabBarController?.tabBar.frame.height)!, width:(self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
        }, completion: { finished in
//            self.tabBarController?.tabBar.isUserInteractionEnabled = true
        })
    }
    
    func hideTabBarView(){
//        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.tabBarController?.tabBar.frame = CGRect(x:(self.tabBarController?.tabBar.frame.minX)!, y:(self.tabBarController?.tabBar.frame.minY)! + 100, width:(self.tabBarController?.tabBar.frame.width)!, height: (self.tabBarController?.tabBar.frame.height)!)
        }, completion: { finished in
            
        })
    }
    
    
    let captureSession = AVCaptureSession()
//    let videoOutput = AVCaptureVideoDataOutput()
    let movieOutput = AVCaptureMovieFileOutput()
//    let audioOutput = AVCaptureAudioDataOutput()
    let previewView = PreviewView()
    let recordButton = UIView()
    
    let progressBar = UIProgressView()
    
    let goToEdit = UIView()
    
    let deleteLast = UIView()
    
    var recordingUrlList : [URL] = [] {
        didSet{
            if !recordingUrlList.isEmpty{
                goToEdit.isHidden = false
                deleteLast.isHidden = false
            }else{
                goToEdit.isHidden = true
                deleteLast.isHidden = true
            }
        }
    }
    var recordingLengthList : [Double] = []
    var recordingBlockViews : [UIView] = []
    
    
    @objc func handleDeleteButtonTap(tapGesture: UITapGestureRecognizer) {
        tapGesture.view?.superview?.layer.sublayers?.removeAll()
        tapGesture.view?.superview?.removeFromSuperview()
    }
    
    func displayRecordedVideo(videoURL: URL){
        
        let videoPlaybackView = UIView()
        
        let videoPlaybackPlayer = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: videoPlaybackPlayer)
//        playerLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        videoPlaybackView.layer.addSublayer(playerLayer)
        
        self.view.addSubview(videoPlaybackView)
        videoPlaybackView.translatesAutoresizingMaskIntoConstraints = false
        videoPlaybackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        videoPlaybackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        videoPlaybackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        videoPlaybackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        updateViewConstraints()
        self.view.layoutSubviews()
        
        playerLayer.frame = CGRect(x: 0, y: 0, width: videoPlaybackView.frame.width, height: videoPlaybackView.frame.height)
        
        let deleteButton = UIView(frame: CGRect(x: 50, y: 50, width: 70, height: 70))
        deleteButton.backgroundColor = .red
        videoPlaybackView.addSubview(deleteButton)
        deleteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleDeleteButtonTap(tapGesture:))))
        
        
        
        playerLayer.videoGravity = .resizeAspectFill
        videoPlaybackPlayer.play()
        
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object:   videoPlaybackPlayer.currentItem, queue: .main) { [weak self] _ in
            videoPlaybackPlayer.seek(to: CMTime.zero)
            videoPlaybackPlayer.play()
        }
    }

    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?){
//        print("DID FINSIH RECORDING", error)
        self.recordButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
        showTabBarView()
        recordingUrlList.append(outputFileURL)
        recordingLengthList.append(output.recordedDuration.seconds)
//        displayRecordedVideo(videoURL: outputFileURL)
        
        
//        progressBar.setProgress(Float(output.recordedDuration.seconds/60), animated: true)
        progressBar.setProgress(Float(recordingLengthList.reduce(0, +)/60), animated: true)
        let segView = UIView(frame: CGRect(x: progressBar.frame.width * CGFloat(progressBar.progress), y: 40, width: 1, height: 5))
        segView.backgroundColor = .white
        recordingBlockViews.append(segView)
        self.view.addSubview(segView)
        
        
//        DispatchQueue.main.async {
//            self.recordButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
//        }
        
        
    }
    
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]){
//        print("DID START RECORDING")
        self.recordButton.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.7)
        hideTabBarView()
        deleteLast.isHidden = true
        goToEdit.isHidden = true
//        DispatchQueue.main.async{
//            self.recordButton.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.7)
//        }
        
    }

    
    
    
    func cameraSetup(){
        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .back)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
        captureSession.commitConfiguration()
    }
    func microphonesSetup(){
        captureSession.beginConfiguration()
        let audioDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInMicrophone, for: .audio, position: .unspecified)
        guard
            let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice!),
            captureSession.canAddInput(audioDeviceInput)
            else { return }
        captureSession.addInput(audioDeviceInput)
        captureSession.commitConfiguration()
    }
    
//    func videoOutputSetup(){
//        // IF I WANT TO DO THIS THEN I NEED TO ADD
//        // https://developer.apple.com/documentation/avfoundation/avassetwriter
//        captureSession.beginConfiguration() //THIS MIGHT NEED TO MOVE
//        guard captureSession.canAddOutput(videoOutput) else { return }
//        captureSession.sessionPreset = .hd1920x1080
//        captureSession.addOutput(videoOutput)
//        captureSession.commitConfiguration()
//    }
    func movieOutputSetup(){
        captureSession.beginConfiguration() //THIS MIGHT NEED TO MOVE
        guard captureSession.canAddOutput(movieOutput) else { return }
        captureSession.sessionPreset = .hd1920x1080
        captureSession.addOutput(movieOutput)
        captureSession.commitConfiguration()
    }
    
//    func audioOutputSetup(){
//        captureSession.beginConfiguration() //THIS MIGHT NEED TO MOVE
//        guard captureSession.canAddOutput(audioOutput) else { return }
//        captureSession.addOutput(audioOutput)
//        captureSession.commitConfiguration()
//    }
    
    func previewViewSetup(){
        self.previewView.videoPreviewLayer.session = self.captureSession
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        previewView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    @objc func handleMainTap(tapGesture: UITapGestureRecognizer) {
        
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }else{
            let fileName = NSTemporaryDirectory() + NSUUID().uuidString + ".MOV"
            movieOutput.startRecording(to: URL(fileURLWithPath: fileName), recordingDelegate: self)
            
        }
    
        if(tapGesture.state == UIGestureRecognizer.State.began){
            
        }
        
        
        if(tapGesture.state == UIGestureRecognizer.State.changed){
            
        }
        
        if(tapGesture.state == UIGestureRecognizer.State.ended){
        }
        
    }
    
    func overlaySetup(){
        let widthAndHeight = CGFloat(85)
        
        recordButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
        recordButton.layer.cornerRadius = widthAndHeight/2
        self.view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        
        recordButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleMainTap)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(animated){
            showTabBarView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(!animated){
            showTabBarView()
        }
        //PUT CLEANUP CODE HERE
        //CAMERA SHOULD TURN OFF
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.tabBarController?.tabBar.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        self.view.backgroundColor = UIColor(red: 0.086, green: 0.086, blue: 0.086, alpha: 1)
        FileManager.default.clearTmpDirectory()
        cameraSetup()
        microphonesSetup()
//        videoOutputSetup()
        movieOutputSetup()
//        audioOutputSetup()
        previewViewSetup()
        overlaySetup()
        captureSession.startRunning()
        
        
        progressBar.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 40)
        progressBar.progressViewStyle = .bar
        self.view.addSubview(progressBar)
        
        goToEdit.frame = CGRect(x: 250, y: 625, width: 80, height: 40)
        goToEdit.backgroundColor = .gray
        goToEdit.isHidden = true
        self.view.addSubview(goToEdit)
        goToEdit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGoToEditTap)))
        
        
        deleteLast.frame = CGRect(x: 30, y: 625, width: 80, height: 40)
        deleteLast.backgroundColor = .red
        deleteLast.isHidden = true
        self.view.addSubview(deleteLast)
        deleteLast.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleDeleteTap)))
        
        
//        movieOutput.addObserver(self, forKeyPath: "movieOutput.recordedDuration", options: .new, context: nil)
    }
    
    @objc func handleDeleteTap(tapGesture: UITapGestureRecognizer) {
        recordingUrlList.removeLast()
        recordingLengthList.removeLast()
        recordingBlockViews.removeLast().removeFromSuperview()
        progressBar.setProgress(Float(recordingLengthList.reduce(0, +)/60), animated: true)
        
    }
    
    @objc func handleGoToEditTap(tapGesture: UITapGestureRecognizer) {
        let viewControllerB = EditVideoViewController()
        viewControllerB.recordingUrlList = self.recordingUrlList
        viewControllerB.recordingLengthList = self.recordingLengthList
        navigationController?.pushViewController(viewControllerB, animated: true)
    }
    
}

