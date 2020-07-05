//
//  ThirdViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation



class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

class ThirdViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?){
        DispatchQueue.main.async {
            self.recordButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
        }
        
        
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]){
        DispatchQueue.main.async{
            self.recordButton.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.7)
        }
        
    }

    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let movieOutput = AVCaptureMovieFileOutput()
    let audioOutput = AVCaptureAudioDataOutput()
    let previewView = PreviewView()
    let recordButton = UIView()

    
    
    internal func captureOutput(_: AVCaptureOutput, didOutput: CMSampleBuffer, from: AVCaptureConnection){
        print("new video frame was written.")
        print(didOutput)
    }
    internal func captureOutput(_: AVCaptureOutput, didDrop: CMSampleBuffer, from: AVCaptureConnection){
        print("video frame was discarded.")
    }
    
    
    
    
    
    func cameraSetup(){
        captureSession.beginConfiguration()
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .unspecified)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
        captureSession.commitConfiguration()
    }
    
    func videoOutputSetup(){
        // IF I WANT TO DO THIS THEN I NEED TO ADD
        // https://developer.apple.com/documentation/avfoundation/avassetwriter
        captureSession.beginConfiguration() //THIS MIGHT NEED TO MOVE
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.sessionPreset = .hd1920x1080
        captureSession.addOutput(videoOutput)
        captureSession.commitConfiguration()
    }
    func movieOutputSetup(){
        captureSession.beginConfiguration() //THIS MIGHT NEED TO MOVE
        guard captureSession.canAddOutput(movieOutput) else { return }
        captureSession.sessionPreset = .hd1920x1080
        captureSession.addOutput(movieOutput)
        captureSession.commitConfiguration()
    }
    
    func audioOutputSetup(){
        captureSession.beginConfiguration() //THIS MIGHT NEED TO MOVE
        guard captureSession.canAddOutput(audioOutput) else { return }
        captureSession.addOutput(audioOutput)
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
    
    @objc func handleMainTap(tapGesture: UITapGestureRecognizer) {
        
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }else{
            movieOutput.startRecording(to: URL(fileURLWithPath: "./1"), recordingDelegate: self)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cameraSetup()
//        videoOutputSetup()
        movieOutputSetup()
//        audioOutputSetup()
        previewViewSetup()
        overlaySetup()
    
        captureSession.startRunning()
        
        
//        let serialQueue = DispatchQueue(label: "VideoSampleBufferQueue")
//        videoOutput.setSampleBufferDelegate(self, queue: serialQueue)
    }
    
    
}

