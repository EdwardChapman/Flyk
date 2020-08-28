//
//  FinishedVideoViewController.swift
//  Flyk
//
//  Created by Edward Chapman on 7/14/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation



class FinishedVideoViewController : UIViewController, UITextViewDelegate, URLSessionTaskDelegate {
    
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    var finishedViewURL: URL? {
        didSet{
            playerLayer.player = videoPlaybackPlayer
            self.videoLoadingSpinner.stopAnimating()
        }
    }
    
    var savedVideoData: NSManagedObject? {
        didSet {
            guard let savedVideoData = self.savedVideoData else {return}
            if let savedVidDesc = savedVideoData.value(forKey: "videoDescription") as? String {
                self.descriptionInput.text = savedVidDesc
                if self.descriptionInput.text.count > 0 {
                    self.descriptionLabel.isHidden = true
                }
            }
            if let allowReac = savedVideoData.value(forKey: "allowReactions") as? Bool {
                self.reactionsSwitch.isOn = allowReac
            }
            if let allowComms = savedVideoData.value(forKey: "allowComments") as? Bool {
                self.commentsSwitch.isOn = allowComms
            }
            if let savedURL = savedVideoData.value(forKey: "filename") as? String {
                let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    .appendingPathComponent(savedURL)
                self.finishedViewURL = documentsUrl
            }
            self.backButton.isHidden = true
        }
    }
    
    
    
    let playerLayer = AVPlayerLayer()
    var videoPlaybackViewLeadingAnchor : NSLayoutConstraint!
    var videoPlaybackViewTopAnchor : NSLayoutConstraint!
    var videoPlaybackViewWidthAnchorSmall : NSLayoutConstraint!
    var videoPlaybackViewWidthAnchorBig : NSLayoutConstraint!
    var videoPlaybackViewHeightAnchor : NSLayoutConstraint!
    let descriptionLabel = UILabel()
    let characterCounter = UILabel()
    let descriptionInput = UITextView()
    
    let reactionsSwitch: UISwitch = {
        let s = UISwitch(frame: .zero)
        s.setOn(true, animated: false)
        return s
    }()
    let commentsSwitch: UISwitch = {
        let s = UISwitch(frame: .zero)
        s.setOn(true, animated: false)
        return s
    }()
    
    let videoLoadingSpinner: UIActivityIndicatorView = {
        let spn = UIActivityIndicatorView(style: .white)
        spn.startAnimating()
        return spn
    }()
    
    lazy var videoPlaybackView : UIView = {
        let videoPlaybackView = UIView()
        self.playerLayer.backgroundColor = UIColor.flykLightDarkGrey.cgColor
        videoPlaybackView.layer.cornerRadius = 8
        videoPlaybackView.clipsToBounds = true
        videoPlaybackView.layer.addSublayer(playerLayer)
        self.view.addSubview(videoPlaybackView)
        videoPlaybackView.translatesAutoresizingMaskIntoConstraints = false
        videoPlaybackViewLeadingAnchor = videoPlaybackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8)
        videoPlaybackViewLeadingAnchor.isActive = true
        
        videoPlaybackViewTopAnchor = videoPlaybackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8)
        videoPlaybackViewTopAnchor.isActive = true
        
        videoPlaybackViewWidthAnchorSmall = videoPlaybackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4)
        videoPlaybackViewWidthAnchorSmall.isActive = true
        
        videoPlaybackViewWidthAnchorBig = videoPlaybackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -16)
        videoPlaybackViewWidthAnchorBig.isActive = false
        
        videoPlaybackViewHeightAnchor = videoPlaybackView.heightAnchor.constraint(equalTo: videoPlaybackView.widthAnchor, multiplier: 16/9)
        videoPlaybackViewHeightAnchor.isActive = true
//        self.view.layoutIfNeeded()
//        videoPlaybackView.frame = self.view.frame
        self.view.addSubview(self.videoLoadingSpinner)
        self.videoLoadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        self.videoLoadingSpinner.centerXAnchor.constraint(equalTo: videoPlaybackView.centerXAnchor).isActive = true
        self.videoLoadingSpinner.centerYAnchor.constraint(equalTo: videoPlaybackView.centerYAnchor).isActive = true
        self.videoLoadingSpinner.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.videoLoadingSpinner.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        self.videoLoadingSpinner.startAnimating()
        self.view.layoutSubviews()
        
        
        playerLayer.frame = videoPlaybackView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        return videoPlaybackView
    }()
    lazy var videoPlaybackPlayer: AVPlayer = {
        let videoPlaybackPlayer = AVPlayer(url: finishedViewURL!)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object:   videoPlaybackPlayer.currentItem, queue: .main) { [weak self] _ in
            self?.videoPlaybackPlayer.seek(to: CMTime.zero)
            self?.videoPlaybackPlayer.play()
        }
        videoPlaybackPlayer.play()
        return videoPlaybackPlayer
    }()
    
    let backButton = UIImageView()
    
    let uploadLater = UIView()
    let uploadNow = UIView()
    
    let blueProgressView = UIView()
    var blueProgressViewWidthAnchor: NSLayoutConstraint?
    
    var isProcessing: Bool = false {
        didSet {
            if self.isProcessing {
                self.blueProgressView.backgroundColor = .white
                
                let processingBar = self.uploadProgressBar
                var pBStart: CGFloat = -processingBar.frame.width - 35
                var counter = 0
                while(pBStart < processingBar.frame.width){
                    counter+=1
                    let slantBar = UIView()
                    processingBar.addSubview(slantBar)
                    slantBar.backgroundColor = .flykBlue
                    slantBar.frame = CGRect(
                        x: pBStart,
                        y: 0,
                        width: 25,
                        height: processingBar.frame.height*1.5
                    )
                    slantBar.center.y = processingBar.bounds.height/2
                    pBStart += 2*slantBar.frame.width
                    slantBar.transform = slantBar.transform.rotated(by: 3.14*(1/6))
                }
                let posMov: CGFloat = CGFloat((Int(processingBar.frame.width/10)+2)*10)
                for slant in processingBar.subviews {
                    if slant == self.blueProgressView {continue}
                    if let _ = slant as? UILabel {continue}
                    UIView.animate(withDuration: 4, delay: 0, options: [.curveLinear, .repeat], animations: {
//                        UIView.setAnimationRepeatCount(1)
                        slant.center.x += posMov
                    }, completion: { (finished) in
                        
                        
                    })
                }
            } else {
                
            }
        }
    }
    
    func updateProgressPercentage(newPercent: CGFloat) {
        print(newPercent)
        blueProgressViewWidthAnchor?.constant = newPercent * (self.view.frame.width)
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            if newPercent == 1 {
                self.isProcessing = true
            }
            }
    }
    
    lazy var uploadProgressBar: UIView = {
        let v = UIView()
        self.view.addSubview(v)
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.flykDarkWhite.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        v.trailingAnchor.constraint(equalTo: self.uploadNow.trailingAnchor).isActive = true
        v.bottomAnchor.constraint(equalTo: self.uploadNow.bottomAnchor).isActive = true
        v.leadingAnchor.constraint(equalTo: self.uploadLater.leadingAnchor).isActive = true
        v.topAnchor.constraint(equalTo: self.uploadNow.topAnchor).isActive = true
        v.clipsToBounds = true
        let bV = self.blueProgressView
        v.addSubview(bV)
        bV.backgroundColor = UIColor.flykBlue
        bV.translatesAutoresizingMaskIntoConstraints = false
        bV.leadingAnchor.constraint(equalTo: v.leadingAnchor).isActive = true
        bV.topAnchor.constraint(equalTo: v.topAnchor).isActive = true
        bV.bottomAnchor.constraint(equalTo: v.bottomAnchor).isActive = true
        blueProgressViewWidthAnchor = bV.widthAnchor.constraint(equalToConstant: 0)
        self.blueProgressViewWidthAnchor?.isActive = true
        
        let vLabel = UILabel()
        vLabel.text = "Uploading"
        vLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        vLabel.textColor = UIColor.flykDarkWhite
        vLabel.textAlignment = .center
        v.addSubview(vLabel)
        vLabel.translatesAutoresizingMaskIntoConstraints = false
        vLabel.leadingAnchor.constraint(equalTo: v.leadingAnchor).isActive = true
        vLabel.trailingAnchor.constraint(equalTo: v.trailingAnchor).isActive = true
        vLabel.topAnchor.constraint(equalTo: v.topAnchor).isActive = true
        vLabel.bottomAnchor.constraint(equalTo: v.bottomAnchor).isActive = true
//        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLaterUpload)))
        
        
        
        v.isHidden = true
        return v
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.hideTabBarView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.videoPlaybackPlayer.pause()
        if let _ = self.savedVideoData {
            self.tabBarController?.showTabBarView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.flykDarkGrey
//        backButton.layer.cornerRadius = 45/2
//        backButton.layer.borderColor = UIColor.white.cgColor
//        backButton.layer.borderWidth = 1
//        backButton.backgroundColor = UIColor.flykMediumGrey
        backButton.image = UIImage(named: "xArrowHollowGrey")
        backButton.contentMode = .scaleAspectFill
        backButton.isUserInteractionEnabled = true
        self.view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15).isActive = true
        backButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor).isActive = true
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBackButtonTap(tapGesture:))))
        
        setupSwitches()
        setupUploadButtons()
        
        
        descriptionInput.backgroundColor = .clear
        descriptionInput.textColor = .white
        descriptionInput.delegate = self
//        descriptionInput.font = descriptionInput.font?.withSize(18)
        self.view.addSubview(descriptionInput)
        descriptionInput.translatesAutoresizingMaskIntoConstraints = false
        descriptionInput.topAnchor.constraint(equalTo: self.videoPlaybackView.topAnchor).isActive = true
        descriptionInput.bottomAnchor.constraint(equalTo: self.videoPlaybackView.bottomAnchor).isActive = true
        descriptionInput.leadingAnchor.constraint(equalTo: self.videoPlaybackView.trailingAnchor, constant: 8).isActive = true
        descriptionInput.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6, constant: -20).isActive = true
        
        
        
        
        descriptionLabel.frame = CGRect(x: descriptionInput.textContainerInset.left, y: descriptionInput.textContainerInset.top, width: 80, height: 30)
        descriptionLabel.text = "Description"
        descriptionLabel.font = descriptionLabel.font.withSize(17)
        descriptionLabel.textColor = .flykGrey
        descriptionLabel.frame.size = descriptionLabel.attributedText!.size()
        descriptionInput.addSubview(descriptionLabel)
        
        
        
        
        descriptionInput.font = descriptionLabel.font
        
        characterCounter.textColor = .darkGray
        characterCounter.font = characterCounter.font.withSize(14)
        descriptionInput.addSubview(characterCounter)
        
        
        
        videoPlaybackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleVideoPlaybackViewTap(tapGesture:))))
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMainViewTap(tapGesture:))))
        
        
        
        
    }
    
    func setupUploadButtons(){
        
        self.view.addSubview(uploadLater)
        uploadLater.backgroundColor = .flykDarkWhite
        uploadLater.layer.cornerRadius = 12
        uploadLater.translatesAutoresizingMaskIntoConstraints = false
        uploadLater.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8).isActive = true
        uploadLater.bottomAnchor.constraint(equalTo: self.backButton.topAnchor, constant: -20).isActive = true
        uploadLater.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5, constant: -12).isActive = true
        uploadLater.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let uploadLaterText = UILabel()
        uploadLaterText.text = "Upload Later"
        uploadLaterText.font = UIFont.boldSystemFont(ofSize: 16.0)
        uploadLaterText.textColor = .flykDarkGrey
        uploadLaterText.textAlignment = .center
        uploadLater.addSubview(uploadLaterText)
        uploadLaterText.translatesAutoresizingMaskIntoConstraints = false
        uploadLaterText.leadingAnchor.constraint(equalTo: uploadLater.leadingAnchor).isActive = true
        uploadLaterText.trailingAnchor.constraint(equalTo: uploadLater.trailingAnchor).isActive = true
        uploadLaterText.topAnchor.constraint(equalTo: uploadLater.topAnchor).isActive = true
        uploadLaterText.bottomAnchor.constraint(equalTo: uploadLater.bottomAnchor).isActive = true
        uploadLater.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLaterUpload)))
        
        
        uploadNow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        self.view.addSubview(uploadNow)
        uploadNow.backgroundColor = .flykBlue
        uploadNow.layer.cornerRadius = 12
        uploadNow.translatesAutoresizingMaskIntoConstraints = false
        uploadNow.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8).isActive = true
        uploadNow.bottomAnchor.constraint(equalTo: uploadLater.bottomAnchor, constant: 0).isActive = true
        uploadNow.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5, constant: -12).isActive = true
        uploadNow.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let uploadNowText = UILabel()
        uploadNowText.text = "Upload Now"
        uploadNowText.font = UIFont.boldSystemFont(ofSize: 16.0)
        uploadNowText.textColor = .white
        uploadNowText.textAlignment = .center
        uploadNow.addSubview(uploadNowText)
        uploadNowText.translatesAutoresizingMaskIntoConstraints = false
        uploadNowText.leadingAnchor.constraint(equalTo: uploadNow.leadingAnchor).isActive = true
        uploadNowText.trailingAnchor.constraint(equalTo: uploadNow.trailingAnchor).isActive = true
        uploadNowText.topAnchor.constraint(equalTo: uploadNow.topAnchor).isActive = true
        uploadNowText.bottomAnchor.constraint(equalTo: uploadNow.bottomAnchor).isActive = true
    }
    
    
    func playbackViewStoreAnimation(goToDrafts: Bool) {
        guard let tbc = self.tabBarController else { return }
        
        if tbc.tabBar.isHidden {
            
            self.view.isUserInteractionEnabled = false
            self.tabBarController?.showTabBarView()
            
            self.videoPlaybackViewLeadingAnchor.isActive = false
            self.videoPlaybackViewTopAnchor.isActive = false
            self.videoPlaybackViewWidthAnchorSmall.isActive = false
            self.videoPlaybackViewWidthAnchorBig.isActive = false
            let startFrame = self.videoPlaybackView.frame
            self.videoPlaybackView.frame = self.view.convert(startFrame, to: self.tabBarController?.view)
            self.tabBarController?.view.addSubview(videoPlaybackView)
            
            let newPlayBackWidth: CGFloat = 18
            let newPlaybackSize = CGSize(width: newPlayBackWidth, height: newPlayBackWidth*(16/9))
            UIView.animate(withDuration: 1, animations: {
                //                self.view.layoutIfNeeded()
                
                self.videoPlaybackView.frame.size = newPlaybackSize
                self.videoPlaybackView.frame.origin = CGPoint(
                    x: (self.tabBarController?.tabBar.frame.maxX)! - 40,
                    y: (self.tabBarController?.tabBar.frame.minY)! + 5
                )
                
                //ANIMATE THE PREVIEW VIEW GOING TOWARDS USER PROFILE
                // deactivate top anchor
                // deactivate leading anchor
                // deactivate width anchor
                // deactivate height anchor
                
            }) { (finished) in
                
                //                if let takeVidVCIndex = self.navigationController?.viewControllers.firstIndex(where: { (curVc) -> Bool in
                //                    if curVc is TakeVideoViewController {
                //                        return true
                //                    }else{
                //                        return false
                //                    }
                //                }) {
                //
                //                }
                self.videoPlaybackView.removeFromSuperview()
                self.playerLayer.player?.pause()
                let oldNav = self.navigationController
//                self.navigationController?.popToRootViewController(animated: false)
                self.tabBarController!.selectedIndex = 4
                if let profileNavController = self.tabBarController?.viewControllers?[4] as? UINavigationController {
                    if let myProfile = profileNavController.viewControllers.first as? MyProfileVC {
                        self.tabBarController?.showTabBarView()
                        myProfile.shouldGoToDrafts = goToDrafts
                    }
                }
                oldNav?.popToRootViewController(animated: false)
            }
            
        }else{
            //            self.tabBarController?.hideTabBarView()
            //            generator.impactOccurred()
        }
    }
    
    
    @objc func handleLaterUpload(tapGesture: UITapGestureRecognizer) {

        if finishedViewURL == nil {return}
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        if let savedVideoData = self.savedVideoData {
            
            
            savedVideoData.setValue(self.commentsSwitch.isOn, forKey: "allowComments")
            savedVideoData.setValue(self.reactionsSwitch.isOn, forKey: "allowReactions")
            savedVideoData.setValue(descriptionInput.text, forKey: "videoDescription")
            savedVideoData.setValue("Saved", forKey: "uploadStatus")
            savedVideoData.setValue(0, forKey: "uploadProgress")
            
            
            
            do {
                try context.save()
            } catch {
                print("Failed saving")
                return;
            }
            self.navigationController?.popToRootViewController(animated: true)
            
            
        } else {
            playbackViewStoreAnimation(goToDrafts: true)
            
            
            let videoName = UUID().uuidString+".mov"
            let videoDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent(videoName)
            
            do{
                try FileManager.default.moveItem(at: finishedViewURL!, to: videoDocumentsURL)
            }catch {
                print("FAILED MOVING VIDEO FILE")
                return;
            }
            
            let entity = NSEntityDescription.entity(forEntityName: "Draft", in: context)
            let draft = NSManagedObject(entity: entity!, insertInto: context)
            
            
            draft.setValue(videoName, forKey: "filename")
            draft.setValue(Date(), forKey: "creationDate")
            draft.setValue(self.commentsSwitch.isOn, forKey: "allowComments")
            draft.setValue(self.reactionsSwitch.isOn, forKey: "allowReactions")
            draft.setValue(descriptionInput.text, forKey: "videoDescription")
            draft.setValue("Saved", forKey: "uploadStatus")
            draft.setValue(0, forKey: "uploadProgress")
     
            
            
            do {
                try context.save()
            } catch {
                print("Failed saving")
                return;
            }
        }

        
        
        
        
        
    }
    @objc func handleUploadTap(tapGesture: UITapGestureRecognizer) {
        if finishedViewURL == nil {return}
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
//        playbackViewStoreAnimation()
        // HERE WE PASS THE STUFF TO ALLOW THE UPLOAD TO HAPPEN
        // USE COREDATA TO STORE IT HERE
        
        self.uploadLater.isHidden = true
        self.uploadNow.isHidden = true
        self.uploadProgressBar.isHidden = false
        

            
            
            
        ////////////////////////////////////////////
        /*
        let cellOverlay = UIView()
        cell.addSubview(cellOverlay)
        cellOverlay.translatesAutoresizingMaskIntoConstraints = false
        cellOverlay.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
        cellOverlay.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
        cellOverlay.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        cellOverlay.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
        let uploadProgressView = UIView()
        uploadProgressView.backgroundColor = .flykBlue
        uploadProgressView.alpha = 0.7
        cellOverlay.addSubview(uploadProgressView)
        uploadProgressView.translatesAutoresizingMaskIntoConstraints = false
        let bottomTopAnchor = uploadProgressView.topAnchor.constraint(equalTo: cellOverlay.bottomAnchor)
        bottomTopAnchor.isActive = true
        let topTopAnchor = uploadProgressView.topAnchor.constraint(equalTo: cellOverlay.topAnchor)
        topTopAnchor.isActive = false
        uploadProgressView.bottomAnchor.constraint(equalTo: cellOverlay.bottomAnchor).isActive = true
        uploadProgressView.leadingAnchor.constraint(equalTo: cellOverlay.leadingAnchor).isActive = true
        uploadProgressView.trailingAnchor.constraint(equalTo: cellOverlay.trailingAnchor).isActive = true
        
        let uploadingLabel = UILabel()
        cellOverlay.addSubview(uploadingLabel)
        uploadingLabel.text = "Uploading"
        uploadingLabel.textColor = .white
        uploadingLabel.translatesAutoresizingMaskIntoConstraints = false
        uploadingLabel.centerXAnchor.constraint(equalTo: cellOverlay.centerXAnchor).isActive = true
        uploadingLabel.centerYAnchor.constraint(equalTo: cellOverlay.centerYAnchor).isActive = true
        */
        ///////////////////////////////////////////////////////
        
        
        //            ServerUpload.videoUpload(videoUrl: documentsUrl, allowComments: allowComments, allowReactions: allowReactions, videoDescription: videoDescription)
        guard let finishedViewURL = self.finishedViewURL,
            let videoDescription = self.descriptionInput.text
            else {return}
        
        let allowReactions = self.reactionsSwitch.isOn
        let allowComments = self.commentsSwitch.isOn
        
    
        
        let endPointURL = FlykConfig.uploadEndpoint+"/upload"
        //        let img = UIImage(contentsOfFile: fullPath)
        var data: NSData;
        do {
            try data = NSData(contentsOf: finishedViewURL)
        }catch{
            print("URL FAIL")
            return
        }
        
        
        
        let boundary = "?????"
        var request = URLRequest(url: URL(string: endPointURL)!)
        request.timeoutInterval = 660
        request.httpMethod = "POST"
        //                request.httpBody = MultiPartPost.photoDataToFormData(data: data, boundary: boundary, fileName: "video", allowComments: allowComments, allowReactions: allowReactions, videoDescription: videoDescription) as Data
        //            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.addValue("multipart/form-data;boundary=\"" + boundary+"\"",
                         forHTTPHeaderField: "Content-Type")
        request.addValue("video/mp4", forHTTPHeaderField: "mimeType")
        //                request.addValue(String((request.httpBody! as NSData).length), forHTTPHeaderField: "Content-Length")
        
        request.addValue("text/plain", forHTTPHeaderField: "Accept")
        
        let prevDataTaskDel = URLSession.shared.delegate
        
        var session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        session = URLSession.shared
        let uploadTask = session.uploadTask(with: request, from: MultiPartPost.photoDataToFormData(data: data, boundary: boundary, fileName: "video", allowComments: allowComments, allowReactions: allowReactions, videoDescription: videoDescription) as Data)
        
        { data, response, error in
//            print(data, response)
            if error != nil || data == nil {
                print("Client error!")
//                        self.savedVideosData[indexPath.row].setValue("failed", forKey: "uploadStatus")
                DispatchQueue.main.async {
//                            self.reloadData()
                    self.uploadNow.isHidden = false
                    self.uploadLater.isHidden = false
                    self.uploadProgressBar.isHidden = true
                }
                return
            }
            guard let response = response as? HTTPURLResponse
                else{print("resopnse is not httpurlResponse"); return;}
            print("Status: ", response.statusCode)
            
            
            
            if response.statusCode == 200 {
                print("SUCCESS")
                DispatchQueue.main.async {
                    if let vidDataObj = self.savedVideoData {
                        self.context.delete(vidDataObj)
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        self.playbackViewStoreAnimation(goToDrafts: false)
                    }
                }
//                        self.savedVideosData = self.fetchDraftEntityList()

                
            } else {
                DispatchQueue.main.async {
//                            self.reloadData()
                    self.uploadNow.isHidden = false
                    self.uploadLater.isHidden = false
                    self.uploadProgressBar.isHidden = true
                }
            }
        }
        print("Upload Started")
        uploadTask.resume()
        
        
//        func watchProgress() {
//            print(uploadTask.progress.fractionCompleted)
//            if uploadTask.progress.isFinished ||
//                uploadTask.progress.isCancelled ||
//                uploadTask.progress.isIndeterminate {
//                return
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                self.updateProgressPercentage(newPercent: CGFloat(uploadTask.progress.fractionCompleted))
//                watchProgress()
//            }
//        }
//        watchProgress()
        
        
        
        
        
        /*
         let task = URLSession.shared.dataTask(with: request) { data, response, error in
         print(data, response)
         if error != nil || data == nil {
         print("Client error!")
         self.savedVideosData[indexPath.row].setValue("failed", forKey: "uploadStatus")
         DispatchQueue.main.async {
         self.reloadData()
         }
         return
         }
         guard let response = response as? HTTPURLResponse
         else{print("resopnse is not httpurlResponse"); return;}
         print("Status: ", response.statusCode)
         
         
         
         if response.statusCode == 200 {
         print("SUCCESS")
         self.context.delete(self.savedVideosData[indexPath.row])
         self.savedVideosData = self.fetchDraftEntityList()
         DispatchQueue.main.async {
         self.reloadData()
         }
         
         } else {
         self.savedVideosData[indexPath.row].setValue("failed", forKey: "uploadStatus")
         DispatchQueue.main.async {
         self.reloadData()
         }
         }
         }
         
         print("Upload Started")
         task.resume()
         */

        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//
//        let entity = NSEntityDescription.entity(forEntityName: "Draft", in: context)
//        let draft = NSManagedObject(entity: entity!, insertInto: context)
//
//        draft.setValue(videoName, forKey: "filename")
//        draft.setValue(Date(), forKey: "creationDate")
//        draft.setValue(self.commentsSwitch.isOn, forKey: "allowComments")
//        draft.setValue(self.reactionsSwitch.isOn, forKey: "allowReactions")
//        draft.setValue(descriptionInput.text, forKey: "videoDescription")
//        draft.setValue("ShouldUpload", forKey: "uploadStatus")
//        draft.setValue(0, forKey: "uploadProgress")
        
        
//        ServerUpload.videoUpload(videoUrl: videoDocumentsURL)
//        do {
//            try context.save()
//        } catch {
//            print("Failed saving")
//            return;
//        }
        
        
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print(totalBytesSent, totalBytesExpectedToSend)
        self.updateProgressPercentage(newPercent: CGFloat(totalBytesSent/totalBytesExpectedToSend))
    }
    
    
    
    
    
    func setupSwitches(){

        self.view.addSubview(reactionsSwitch)
//        reactionsSwitch.isOn = true
        reactionsSwitch.translatesAutoresizingMaskIntoConstraints = false
        reactionsSwitch.frame.size = reactionsSwitch.intrinsicContentSize
        reactionsSwitch.tintColor = .flykLightDarkGrey
        
        let superWidth = self.view.frame.width
        let videoPlayerBottom = 0.4*superWidth*(16/9)+8
        let topConst = videoPlayerBottom+40
        reactionsSwitch.onTintColor = .flykBlue
        reactionsSwitch.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(topConst)).isActive = true
        reactionsSwitch.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        reactionsSwitch.widthAnchor.constraint(equalToConstant: reactionsSwitch.intrinsicContentSize.width).isActive = true
        reactionsSwitch.heightAnchor.constraint(equalToConstant: reactionsSwitch.intrinsicContentSize.height).isActive = true
        
        let reactionsLabel = UILabel(frame: .zero)
        reactionsLabel.textColor = .flykDarkWhite
        self.view.addSubview(reactionsLabel)
        reactionsLabel.translatesAutoresizingMaskIntoConstraints = false
        reactionsLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        reactionsLabel.trailingAnchor.constraint(equalTo: reactionsSwitch.leadingAnchor, constant: -8).isActive = true
        reactionsLabel.centerYAnchor.constraint(equalTo: reactionsSwitch.centerYAnchor).isActive = true
        reactionsLabel.text = "Allow Reactions"
        reactionsLabel.adjustsFontSizeToFitWidth = true
        
        
        
        
        commentsSwitch.tintColor = .flykLightDarkGrey
//        commentsSwitch.isOn = true
        self.view.addSubview(commentsSwitch)
        commentsSwitch.translatesAutoresizingMaskIntoConstraints = false
        commentsSwitch.frame.size = commentsSwitch.intrinsicContentSize
        
//        let superWidth = self.view.frame.width
//        let videoPlayerBottom = 0.4*superWidth*(16/9)+8
//        let topConst = videoPlayerBottom+40
        commentsSwitch.onTintColor = .flykBlue
        commentsSwitch.topAnchor.constraint(equalTo: reactionsSwitch.bottomAnchor, constant: 35).isActive = true
        commentsSwitch.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        commentsSwitch.widthAnchor.constraint(equalToConstant: commentsSwitch.intrinsicContentSize.width).isActive = true
        commentsSwitch.heightAnchor.constraint(equalToConstant: commentsSwitch.intrinsicContentSize.height).isActive = true
        
        let commentsSwitchLabel = UILabel(frame: .zero)
        commentsSwitchLabel.textColor = .flykDarkWhite
        self.view.addSubview(commentsSwitchLabel)
        commentsSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
        commentsSwitchLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        commentsSwitchLabel.trailingAnchor.constraint(equalTo: commentsSwitch.leadingAnchor, constant: -8).isActive = true
        commentsSwitchLabel.centerYAnchor.constraint(equalTo: commentsSwitch.centerYAnchor).isActive = true
        commentsSwitchLabel.text = "Allow Comments"
        commentsSwitchLabel.adjustsFontSizeToFitWidth = true
        
        
    }
    
    @objc func handleMainViewTap(tapGesture: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionLabel.isHidden = true
    }
    func textViewDidChange(_ textView: UITextView) {
        characterCounter.text = String(textView.text.count)
        let newSize = characterCounter.attributedText!.size()

        characterCounter.frame = CGRect(
            origin: CGPoint(
                x: characterCounter.superview!.bounds.maxX - newSize.width,
                y: characterCounter.superview!.bounds.maxY - newSize.height
            ),
            size: newSize
        )
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count == 0 {
            descriptionLabel.isHidden = false
        }
    }
    
    @objc func handleVideoPlaybackViewTap(tapGesture: UITapGestureRecognizer){
         self.view.endEditing(true)
        if self.videoPlaybackViewWidthAnchorSmall.isActive {
            self.videoPlaybackViewWidthAnchorSmall.isActive = false
            self.videoPlaybackViewWidthAnchorBig.isActive = true
            self.view.layoutSubviews()
            UIView.animate(withDuration: 0.3, animations: {
                self.videoPlaybackView.layer.sublayers![0].frame = self.videoPlaybackView.bounds
            })
        }else{
            self.videoPlaybackViewWidthAnchorBig.isActive = false
            self.videoPlaybackViewWidthAnchorSmall.isActive = true
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutSubviews()
                self.videoPlaybackView.layer.sublayers![0].frame = self.videoPlaybackView.bounds
            })
        }
    }
    
    @objc func handleBackButtonTap(tapGesture: UITapGestureRecognizer){
        if (self.navigationController?.viewControllers.contains(self))! {
            self.playerLayer.player?.pause()
            self.playerLayer.player = nil
            self.navigationController?.popViewController(animated: true)
        }
    }
}
