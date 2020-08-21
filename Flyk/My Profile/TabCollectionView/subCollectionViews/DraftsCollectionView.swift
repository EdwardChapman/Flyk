//
//  DraftsCollectionView.swift
//  Flyk
//
//  Created by Edward Chapman on 8/6/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class DraftsCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    weak var myProfileVC: MyProfileVC?
    
    
    lazy var savedVideosData: [NSManagedObject] = fetchDraftEntityList()
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    
    
    func fetchDraftEntityList() -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Draft")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            return result as! [NSManagedObject]
        } catch {
            print("Failed fetching saved videos", error)
            return []
        }
        //        print(data.entity.attributesByName.keys) //GET ALL KEYS
        //        print(data.value(forKey: "videoUrl") //GET VALUE
    }
    
    
    init(frame: CGRect){
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        
        
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        
//        self.backgroundColor = .flykDarkGrey
        
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "postsCollectionView")
        self.delegate = self
        self.dataSource = self
        self.contentInsetAdjustmentBehavior = .never
        
        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    @objc func handleRefreshControl() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        //        fetchVideoList()
        // Dismiss the refresh control.
        DispatchQueue.main.async { self.refreshControl!.endRefreshing() }
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // COLLECTIONVIEW DELEGATE ///////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedVideosData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.dequeueReusableCell(withReuseIdentifier: "postsCollectionView", for: indexPath)
        cell.backgroundColor = .flykMediumGrey
        
        let savedURL = savedVideosData[indexPath.row].value(forKey: "filename") as! String
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(savedURL)
        
        let uploadStatus = savedVideosData[indexPath.row].value(forKey: "uploadStatus") as! String
        
        
        let videoAsset = AVAsset(url: documentsUrl)
        
        let newPlayer = AVPlayer(url: documentsUrl)
        let playerLayer = AVPlayerLayer()
        playerLayer.player = newPlayer
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = cell.layer.bounds
        cell.layer.addSublayer(playerLayer)
        
        
        
        if uploadStatus == "ShouldUpload" {
            savedVideosData[indexPath.row].setValue("uploading", forKey: "uploadStatus")
            
            let allowComments = savedVideosData[indexPath.row].value(forKey: "allowComments") as! Bool
            let allowReactions = savedVideosData[indexPath.row].value(forKey: "allowReactions") as! Bool
            let videoDescription = savedVideosData[indexPath.row].value(forKey: "videoDescription") as! String
            
            
            
            ////////////////////////////////////////////
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
            ////////////////////////////////////////////////////////
            
            
//            ServerUpload.videoUpload(videoUrl: documentsUrl, allowComments: allowComments, allowReactions: allowReactions, videoDescription: videoDescription)
            
            let videoUrl = documentsUrl
            
            
            let endPointURL = FlykConfig.uploadEndpoint+"/upload"
            //        let img = UIImage(contentsOfFile: fullPath)
            var data: NSData;
            do {
                try data = NSData(contentsOf: videoUrl)
            }catch{
                print("URL FAIL")
                return cell
            }
            
            
            do {
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
                
                
                let uploadTask = URLSession.shared.uploadTask(with: request, from: MultiPartPost.photoDataToFormData(data: data, boundary: boundary, fileName: "video", allowComments: allowComments, allowReactions: allowReactions, videoDescription: videoDescription) as Data) { data, response, error in
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
                uploadTask.resume()
                    
                

        


            
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
            }catch{
                
            }
            
            
            
            
        }
        
        /* THIS IS
         
        let cancelLabel = UILabel()
        cellOverlay.addSubview(cancelLabel)
        cancelLabel.text = "CANCEL"
        cancelLabel.textColor = .white
        cancelLabel.backgroundColor = .red
        cancelLabel.alpha = 0.7
        cancelLabel.layer.cornerRadius = 5
        cancelLabel.clipsToBounds = true
        cancelLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelLabel.centerXAnchor.constraint(equalTo: cellOverlay.centerXAnchor).isActive = true
        cancelLabel.topAnchor.constraint(equalTo: uploadingLabel.bottomAnchor, constant: 20).isActive = true
        
        cell.layoutIfNeeded()
        
        bottomTopAnchor.isActive = false
        topTopAnchor.isActive = true
        
        UIView.animate(withDuration: 5, animations: {
            cell.layoutIfNeeded()
        }) { (finished) in
            
            uploadingLabel.text = "Processing"
            
            cancelLabel.isHidden = true
            let processingBar = UIView()
            cellOverlay.addSubview(processingBar)
            processingBar.translatesAutoresizingMaskIntoConstraints = false
            processingBar.centerXAnchor.constraint(equalTo: cellOverlay.centerXAnchor).isActive = true
            processingBar.topAnchor.constraint(equalTo: uploadingLabel.bottomAnchor, constant: 15).isActive = true
            processingBar.widthAnchor.constraint(equalTo: cellOverlay.widthAnchor, multiplier: 0.7).isActive = true
            processingBar.heightAnchor.constraint(equalToConstant: 25).isActive = true
            processingBar.layer.cornerRadius = 25/2
            processingBar.backgroundColor = .white
            processingBar.clipsToBounds = true
            cell.layoutIfNeeded()
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
                    width: 10,
                    height: processingBar.frame.height*1.5
                )
                slantBar.center.y = processingBar.bounds.height/2
                pBStart += 2*slantBar.frame.width
                slantBar.transform = slantBar.transform.rotated(by: 3.14*(1/6))
            }
            let posMov: CGFloat = CGFloat((Int(processingBar.frame.width/10)+2)*10)
            for slant in processingBar.subviews {
                UIView.animate(withDuration: 4, delay: 0, options: [.curveLinear, .repeat], animations: {
                    UIView.setAnimationRepeatCount(1)
                    slant.center.x += posMov
                }, completion: { (finished) in
                    //                        print("COMPLETED")
                    if slant == processingBar.subviews.last {
                        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                            cellOverlay.alpha = 0
                        }, completion: {(fin) in
                            print(fin)
                            cellOverlay.isHidden = true
                        })
                    }
                })
            }
        }
        */
        
        newPlayer.play()
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.size.width/3
        let height = width*(16/9)
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //        print("DID END DISPLAYING CELL")
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        
        
    }
    
    
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // SCROLLVIEW DELEGATE ///////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //        scrollView.isScrollEnabled = true
        //        self.bounces = false //STOP BOUNCING TO HOPEFULLY PASS UP
    }
    var lastTargetOffsetY: CGFloat?
    var realTargetOffsetY: CGFloat?
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        lastTargetOffsetY = targetContentOffset.pointee.y
        print(lastTargetOffsetY)
        
        
        
        
        //        print(lastTargetOffsetY)
        //        print(scrollView.decelerationRate)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let myProfileVC = self.myProfileVC else {return}
        
        let profileScrollView = myProfileVC.profileScrollView
        
        let pSvHeight = profileScrollView.frame.height
        
        //This is a down drag
        let maxOffset = myProfileVC.profileHeaderView.frame.height - myProfileVC.view.safeAreaInsets.top
        
        if scrollView.contentOffset.y > 0 && profileScrollView.contentOffset.y.rounded(.down) < maxOffset.rounded(.down) {
            var newY = profileScrollView.contentOffset.y + scrollView.contentOffset.y
            if newY > maxOffset {
                newY = maxOffset
            }
            
            profileScrollView.setContentOffset(CGPoint(x: 0, y: newY), animated: false)
            //            scrollView.setContentOffset(.zero, animated: false)
            scrollView.contentOffset = CGPoint.zero
            
            
            //THIS is an up drag
        } else if scrollView.contentOffset.y < 0 && profileScrollView.contentOffset.y.rounded(.down) > 0 {
            var newY = profileScrollView.contentOffset.y + scrollView.contentOffset.y
            if newY < 0 {
                newY = 0
            }
            
            //            profileScrollView.setContentOffset(CGPoint(x: 0, y: newY), animated: false)
            profileScrollView.contentOffset = CGPoint(x: 0, y: newY)
            //            scrollView.setContentOffset(.zero, animated: false)
            scrollView.contentOffset = CGPoint.zero
            
            //up drag with no content left
        } else if scrollView.contentOffset.y < 0 {
            //            scrollView.setContentOffset(.zero, animated: false)
            scrollView.contentOffset = CGPoint.zero
        }
        
    }
    
    
}



