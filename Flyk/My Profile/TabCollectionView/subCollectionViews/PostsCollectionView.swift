//
//  PostsCollectionView.swift
//  Flyk
//
//  Created by Edward Chapman on 8/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class PostsCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    weak var myProfileVC: MyProfileVC?
    
    
    var videoDataList: [NSMutableDictionary] = [] {
        didSet {
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
    }
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    
    
    
    
    init(frame: CGRect){
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
//        print("PostsCollecitonview init")

        
        
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        self.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        self.scrollIndicatorInsets = UIEdgeInsets(top: -100, left: 0, bottom: 0, right: 0)
        
//        self.backgroundColor = .flykDarkGrey
        
        self.register(PostsCell.self, forCellWithReuseIdentifier: "postsCell")
        self.delegate = self
        self.dataSource = self
//        self.contentInsetAdjustmentBehavior = .never
//        self.contentInsetAdjustmentBehavior = .automatic //This sets content offset to zero on push
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
        return videoDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.dequeueReusableCell(withReuseIdentifier: "postsCell", for: indexPath) as! PostsCell
        
        
        /* APNG/GIF SETUP */
        let targetPath = FlykConfig.mainEndpoint+"/video/animatedThumbnail/"
        if let apngFilename = videoDataList[indexPath.row]["apng_filename"] as? String {
            let apngUrl = URL(string: targetPath + apngFilename)
            
            if let apngTestImgView = UIImageView.fromGif(frame: cell.frame, assetUrl: apngUrl, autoReverse: true) {
                apngTestImgView.frame = cell.bounds
                
                cell.swapUIImageGifView(newGifView: apngTestImgView)
                
            }
        }

        
        
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
    
//    func collectionView(_ collectionView: UICollectionView,
//                        didSelectItemAt indexPath: IndexPath) {
//        print("HI")
//    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // push view controller with swipe collectionview
        guard let myProfileVC = self.myProfileVC else {return false}
        
        self.myProfileVC?.navigationController?.pushViewController(
            Home(
                startingIndex: indexPath.row,
                videoDataList: self.videoDataList,
                presentingVC: myProfileVC,
                refreshFunction: {(cb) in
                    cb(nil)
                }
            ),
            animated: true
        )
        
        
        return false
    }
    
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // SCROLLVIEW DELEGATE ///////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    /*
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
        
        
        
        
        
//        print(lastTargetOffsetY)
//        print(scrollView.decelerationRate)
        
    }
    */
    /*
    @objc func addedPanGestureRecFunc(panGesuture: UIPanGestureRecognizer){
        let a = panGesuture.translation(in: self).y
//        self.myProfileVC?.profileScrollView.contentOffset.y -= a
//        panGesuture.setTranslation(.zero, in: self)
    self.myProfileVC?.profileScrollView.panGestureRecognizer.setTranslation(panGesuture.translation(in: self), in: self.myProfileVC?.profileScrollView)
        
    }
    */
    
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
                scrollView.contentOffset.y = scrollView.contentOffset.y / 2.3


                /* This is drag to top when top of profile is hidden */
            } else if scrollView.contentOffset.y < 0 && profileScrollView.contentOffset.y.rounded(.down) > 0 {
                
                var newY = profileScrollView.contentOffset.y + scrollView.contentOffset.y
                if newY < 0 {
                    newY = 0
                }
                

                profileScrollView.setContentOffset(CGPoint(x: 0, y: newY), animated: false)
                scrollView.contentOffset.y = scrollView.contentOffset.y / 2.5

                
                /* This is drag to top when top of profile is fully shown */
            } else if scrollView.contentOffset.y < 0 {
                
//                scrollView.contentOffset = CGPoint.zero
                scrollView.setContentOffset(.zero, animated: false)
                
                
            }
        }

    }
    
    
}


