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
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // push view controller with swipe collectionview
        guard let myProfileVC = self.myProfileVC else {return false}
       
        let finishedVideoVC = FinishedVideoViewController()
        finishedVideoVC.savedVideoData = self.savedVideosData[indexPath.row]
        
        self.myProfileVC?.navigationController?.pushViewController(finishedVideoVC, animated: true)
        return false
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
        
        if let myProfileVC = self.myProfileVC {
            
            let profileScrollView = myProfileVC.profileScrollView
            
            
            /* This is a drag to bottom */
            let maxOffset = myProfileVC.profileHeaderView.frame.height - myProfileVC.view.safeAreaInsets.top
            
            
            let scrollDif = profileScrollView.contentOffset.y.rounded(.down) - maxOffset.rounded(.down)
            
            
            if scrollView.contentOffset.y > 0 && scrollDif < -1 {
                var newY = profileScrollView.contentOffset.y + scrollView.contentOffset.y
                if newY > maxOffset {
                    newY = maxOffset
                }
                
                profileScrollView.setContentOffset(CGPoint(x: 0, y: newY), animated: false)
                
                // removed this to stop jumping content inset on return from push.
                // scrollView.contentOffset = CGPoint.zero
                scrollView.contentOffset = CGPoint(
                    x: scrollView.contentOffset.x,
                    y: scrollView.contentOffset.y / 2.3
                )
                
                
                /* This is drag to top when top of profile is hidden */
            } else if scrollView.contentOffset.y < 0 && profileScrollView.contentOffset.y.rounded(.down) > 0 {
                var newY = profileScrollView.contentOffset.y + scrollView.contentOffset.y
                if newY < 0 {
                    newY = 0
                }
                
                profileScrollView.contentOffset = CGPoint(x: 0, y: newY)
                scrollView.contentOffset = CGPoint(
                    x: scrollView.contentOffset.x,
                    y: scrollView.contentOffset.y / 2.3
                )
                
                
                /* This is drag to top when top of profile is fully shown */
            } else if scrollView.contentOffset.y < 0 {
                scrollView.contentOffset = CGPoint.zero
            }
        }
        
    }
    
    
}



