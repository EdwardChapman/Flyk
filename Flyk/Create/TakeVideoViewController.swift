//
//  ThirdViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation







class TakeVideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    lazy var captureSession : AVCaptureSession = {
        return AVCaptureSession()
    }()
    
    lazy var backCamVideoInput: AVCaptureDeviceInput? = {
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        if let videoDevice = videoDevice {
            if let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) {
                return videoDeviceInput
            }
            return nil
        }
        return nil
    }()
    lazy var selfieCamVideoInput: AVCaptureDeviceInput? = {
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        if let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!) {
            return videoDeviceInput
        }
        return nil
    }()
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    let previewView = PreviewView()
    let progressBar = UIProgressView()
    let recordButton = UIView()
    let goToEdit = UIImageView(image: UIImage(named: "checkNext"))
    let deleteLast = UIImageView(image: UIImage(named: "delete"))
    
    let bottomProgressBar = UIView()
    var bottomProgressBarWidthAnchor: NSLayoutConstraint?
    
    var recordingUrlList : [URL] = [] {
        didSet{
            if !recordingUrlList.isEmpty{
                deleteLast.isHidden = false
            }else{
                deleteLast.isHidden = true
            }
        }
    }
    var recordingLengthList : [Double] = [] {
        didSet{
            if recordingLengthList.reduce(0, +) > 3{
                goToEdit.isHidden = false
                deleteLast.isHidden = false
            }else{
                goToEdit.isHidden = true
            }
        }
    }
    var recordingBlockViews : [UIView] = []
    
    
    

    
    
    
    func cameraSetup(){
        if let backCamVideoInput = self.backCamVideoInput {
            captureSession.beginConfiguration()
            if captureSession.canAddInput(backCamVideoInput) {
                captureSession.addInput(backCamVideoInput)
            }
            captureSession.commitConfiguration()
        }
    }
    func microphonesSetup(){
        captureSession.beginConfiguration()
        let audioDeviceOp = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInMicrophone, for: .audio, position: .unspecified)
        guard
            let audioDevice = audioDeviceOp,
            let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice),
            captureSession.canAddInput(audioDeviceInput)
        else {
            captureSession.commitConfiguration()
            return
        }
        captureSession.addInput(audioDeviceInput)
        captureSession.commitConfiguration()
    }
    

    func movieOutputSetup(){
        captureSession.beginConfiguration() //THIS MIGHT NEED TO MOVE
        guard captureSession.canAddOutput(movieOutput)
        else {
            captureSession.commitConfiguration()
            return
        }
        captureSession.sessionPreset = .hd1920x1080
        captureSession.addOutput(movieOutput)
        captureSession.commitConfiguration()
    }
    
    
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
    
    
    func overlaySetup(){
        
        let widthAndHeight = CGFloat(85)

        recordButton.layer.borderWidth = 3
        recordButton.layer.borderColor = UIColor.white.cgColor
        recordButton.layer.cornerRadius = widthAndHeight/2
        self.view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        recordButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleRecordButtonTap)))
        
        

        goToEdit.frame = CGRect(x: 300, y: 625, width: 40, height: 40)
        goToEdit.isUserInteractionEnabled = true
        goToEdit.contentMode = .scaleAspectFit
        self.view.addSubview(goToEdit)

        goToEdit.translatesAutoresizingMaskIntoConstraints = false
        goToEdit.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        goToEdit.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40).isActive = true
        goToEdit.widthAnchor.constraint(equalToConstant: 40).isActive = true
        goToEdit.heightAnchor.constraint(equalToConstant: 40).isActive = true
        

        goToEdit.isHidden = true
        goToEdit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGoToEditTap)))
        
        

        
        deleteLast.frame = CGRect(x: 30, y: 625, width: 40, height: 40)
        deleteLast.contentMode = .scaleAspectFit
        deleteLast.image = deleteLast.image?.withHorizontallyFlippedOrientation()
        deleteLast.isUserInteractionEnabled = true
        self.view.addSubview(deleteLast)
        deleteLast.translatesAutoresizingMaskIntoConstraints = false
        deleteLast.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40).isActive = true
        deleteLast.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        deleteLast.widthAnchor.constraint(equalToConstant: 40).isActive = true
        deleteLast.heightAnchor.constraint(equalToConstant: 40).isActive = true
        

        deleteLast.isHidden = true
        deleteLast.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleDeleteTap)))
        
        
        let cameraSwitcher = UIImageView()
        cameraSwitcher.image = UIImage(named: "selfieCam")
        cameraSwitcher.isUserInteractionEnabled = true
        cameraSwitcher.contentMode = .scaleAspectFit
//        cameraSwitcher.image = UIImage(named: "frontCam")
        self.view.addSubview(cameraSwitcher)
        cameraSwitcher.translatesAutoresizingMaskIntoConstraints = false
        cameraSwitcher.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12).isActive = true
        cameraSwitcher.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        cameraSwitcher.widthAnchor.constraint(equalToConstant: 35).isActive = true
        cameraSwitcher.heightAnchor.constraint(equalTo: cameraSwitcher.heightAnchor).isActive = true
        cameraSwitcher.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleCameraTypeTap)))
        
        
        bottomProgressBar.backgroundColor = .flykBlue
        self.view.addSubview(bottomProgressBar)
        bottomProgressBar.translatesAutoresizingMaskIntoConstraints = false
        bottomProgressBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        bottomProgressBar.topAnchor.constraint(equalTo: self.previewView.bottomAnchor, constant: -2).isActive = true
        bottomProgressBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.bottomProgressBarWidthAnchor = bottomProgressBar.widthAnchor.constraint(equalToConstant: 0)
        self.bottomProgressBarWidthAnchor?.isActive = true
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(animated){
            self.tabBarController!.showTabBarView()
        }
        captureSession.startRunning()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.flykLightBlack

        cameraSetup()
        microphonesSetup()
        movieOutputSetup()
        previewViewSetup()
        overlaySetup()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(!animated){
            self.tabBarController!.showTabBarView()
        }
        self.captureSession.stopRunning()
        //PUT CLEANUP CODE HERE
        //CAMERA SHOULD TURN OFF
    }
    
    // SWITCH CAMERA TAP
    @objc func handleCameraTypeTap(tapGesture: UITapGestureRecognizer){
        captureSession.beginConfiguration()
        if let backCamVideoInput = self.backCamVideoInput, let selfieCamInput = self.selfieCamVideoInput {
            if captureSession.inputs.contains(backCamVideoInput) {
                captureSession.removeInput(backCamVideoInput)
                if captureSession.canAddInput(selfieCamInput) {
                    captureSession.addInput(selfieCamInput)
                    
                    if let tapImgView = tapGesture.view as? UIImageView {
                        tapImgView.image = UIImage(named: "backCam")
                    }
                }else{
                    captureSession.addInput(backCamVideoInput)
                }
            }else if captureSession.inputs.contains(selfieCamInput) {
                captureSession.removeInput(selfieCamInput)
                if captureSession.canAddInput(backCamVideoInput) {
                    captureSession.addInput(backCamVideoInput)
                    if let tapImgView = tapGesture.view as? UIImageView {
                        tapImgView.image = UIImage(named: "selfieCam")
                    }
                }else{
                    captureSession.addInput(selfieCamInput)
                }
            }
        }
        captureSession.commitConfiguration()
    }
    
    @objc func handleDeleteTap(tapGesture: UITapGestureRecognizer) {
        recordingUrlList.removeLast()
        recordingLengthList.removeLast()
        recordingBlockViews.removeLast().removeFromSuperview()
        
        self.bottomProgressBarWidthAnchor?.constant = CGFloat(recordingLengthList.reduce(0, +)/60)*self.view.frame.width
        self.bottomProgressBar.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }

    
    @objc func handleGoToEditTap(tapGesture: UITapGestureRecognizer) {
        let viewControllerB = EditVideoViewController()
        viewControllerB.recordingUrlList = self.recordingUrlList
//        viewControllerB.recordingLengthList = self.recordingLengthList
        navigationController?.pushViewController(viewControllerB, animated: true)
    }
    
    @objc func handleRecordButtonTap(tapGesture: UITapGestureRecognizer) {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }else{
            let fileName = NSTemporaryDirectory() + NSUUID().uuidString + ".MOV"
            movieOutput.startRecording(to: URL(fileURLWithPath: fileName), recordingDelegate: self)
        }
        if(tapGesture.state == UIGestureRecognizer.State.began){ }
        if(tapGesture.state == UIGestureRecognizer.State.changed){ }
        if(tapGesture.state == UIGestureRecognizer.State.ended){ }
    }
    
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // AVCaptureFileOutputRecordingDelegate ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //DID FINISH RECORDING //I thought this wasn't on main thread but it seems to be?
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?){
        
        self.recordButton.backgroundColor = .clear
        self.tabBarController!.showTabBarView()
        recordingUrlList.append(outputFileURL)
        recordingLengthList.append(output.recordedDuration.seconds)
        self.bottomProgressBar.layer.removeAllAnimations()
        self.bottomProgressBarWidthAnchor?.constant = CGFloat(recordingLengthList.reduce(0, +)/60)*self.view.frame.width
        
        let segView = UIView(frame: CGRect(
            x: (self.view.frame.width * CGFloat(recordingLengthList.reduce(0, +)/60)) - 2,
            y: 0,
            width: 2,
            height: bottomProgressBar.frame.height
            )
        )
        segView.backgroundColor = .white
        bottomProgressBar.addSubview(segView)
        recordingBlockViews.append(segView)
        
    }
    
    
    //DID START RECORDING
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]){
        self.recordButton.backgroundColor = UIColor.flykRecordRed
        
        self.bottomProgressBarWidthAnchor?.constant = self.view.frame.width
        self.bottomProgressBar.layer.removeAllAnimations()
        UIView.animate(withDuration: 60 - recordingLengthList.reduce(0, +), delay: 0, options: [.curveLinear], animations: {
            self.view.layoutIfNeeded()
        })
        
        self.tabBarController!.hideTabBarView()
        deleteLast.isHidden = true
        goToEdit.isHidden = true
        
    }
}


//
// PREVIEWVIEW CUSTOM UIVIEW
//
class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
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

