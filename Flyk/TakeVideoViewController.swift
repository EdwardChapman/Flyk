//
//  ThirdViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation


extension UITabBarController{
    func showTabBarView(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.tabBar.frame = CGRect(x:(self.tabBar.frame.minX), y:(self.view.frame.maxY) - (self.tabBar.frame.height), width:(self.tabBar.frame.width), height: (self.tabBar.frame.height))
        }, completion: { finished in

        })
    }
    
    func hideTabBarView(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.tabBar.frame = CGRect(x:(self.tabBar.frame.minX), y:(self.tabBar.frame.minY) + 100, width:(self.tabBar.frame.width), height: (self.tabBar.frame.height))
        }, completion: { finished in
            
        })
    }
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
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    
    let previewView = PreviewView()
    let progressBar = UIProgressView()
    let recordButton = UIView()
    let goToEdit = UIView()
    let deleteLast = UIView()
    
    
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
    
    
    
    

    //DID FINISH RECORDING //I thought this wasn't on main thread but it seems to be?
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?){
//        print("DID FINSIH RECORDING", error)
        self.recordButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
        self.tabBarController!.showTabBarView()
        recordingUrlList.append(outputFileURL)
        recordingLengthList.append(output.recordedDuration.seconds)
//        displayRecordedVideo(videoURL: outputFileURL)
        
        
//        progressBar.setProgress(Float(output.recordedDuration.seconds/60), animated: true)
        progressBar.setProgress(Float(recordingLengthList.reduce(0, +)/60), animated: true)
        let segView = UIView(frame: CGRect(x: progressBar.frame.width * CGFloat(progressBar.progress), y: 40, width: 1, height: 5))
        segView.backgroundColor = .white
        recordingBlockViews.append(segView)
        self.view.addSubview(segView)
    }
    
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]){
//        print("DID START RECORDING")
        self.recordButton.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.7)
        self.tabBarController!.hideTabBarView()
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
    

    func movieOutputSetup(){
        captureSession.beginConfiguration() //THIS MIGHT NEED TO MOVE
        guard captureSession.canAddOutput(movieOutput) else { return }
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
        recordButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
        recordButton.layer.cornerRadius = widthAndHeight/2
        self.view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: widthAndHeight).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        recordButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleRecordButtonTap)))
        
        
        progressBar.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 40)
        progressBar.progressViewStyle = .bar
        self.view.addSubview(progressBar)
        
        goToEdit.frame = CGRect(x: 250, y: 625, width: 80, height: 40)
        goToEdit.backgroundColor = .gray
        goToEdit.isHidden = true
        goToEdit.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleGoToEditTap)))
        self.view.addSubview(goToEdit)
        
        deleteLast.frame = CGRect(x: 30, y: 625, width: 80, height: 40)
        deleteLast.backgroundColor = .red
        deleteLast.isHidden = true
        deleteLast.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleDeleteTap)))
        self.view.addSubview(deleteLast)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(animated){
            self.tabBarController!.showTabBarView()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 0.086, green: 0.086, blue: 0.086, alpha: 1)

        cameraSetup()
        microphonesSetup()
        movieOutputSetup()
        previewViewSetup()
        overlaySetup()
        captureSession.startRunning()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(!animated){
            self.tabBarController!.showTabBarView()
        }
        //PUT CLEANUP CODE HERE
        //CAMERA SHOULD TURN OFF
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

