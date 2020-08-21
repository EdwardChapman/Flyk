//
//  LikesCollectionView.swift
//  Flyk
//
//  Created by Edward Chapman on 8/8/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//


import UIKit
import CoreData
import AVFoundation

class LikesCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
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
    
    
    func fetchMyPosts(){
        let url = URL(string: FlykConfig.mainEndpoint + "/myProfile/likes")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            
            if(response.statusCode == 200) {
                do {
                    if let videosList : [NSDictionary] = try JSONSerialization.jsonObject(with: data!, options: []) as? [NSDictionary] {
                        self.videoDataList = videosList.map{ dict -> NSMutableDictionary in dict.mutableCopy() as! NSMutableDictionary}
                    }
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
            }else{
                print("Response not 200", response)
            }
            
            }.resume()
        
    }
    
    
    init(frame: CGRect){
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        print("PostsCollecitonview init")
        fetchMyPosts()
        
        
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        
//        self.backgroundColor = .flykDarkGrey
        
        self.register(PostsCell.self, forCellWithReuseIdentifier: "likesCell")
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
        return videoDataList.count
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.dequeueReusableCell(withReuseIdentifier: "likesCell", for: indexPath)
        cell.backgroundColor = .flykMediumGrey
        
        
        /* APNG/GIF SETUP */
        let targetPath = FlykConfig.mainEndpoint+"/video/animatedThumbnail/"
        if let apngFilename = videoDataList[indexPath.row]["apng_filename"] as? String {
            let apngUrl = URL(string: targetPath + apngFilename)
            
            if let apngTestImgView = UIImageView.fromGif(frame: cell.frame, assetUrl: apngUrl, autoReverse: true) {
                apngTestImgView.frame = cell.bounds
                cell.addSubview(apngTestImgView)
                
            }
        }
        return cell
        
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.dequeueReusableCell(withReuseIdentifier: "likesCell", for: indexPath) as! PostsCell
        
        
        
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
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // push view controller with swipe collectionview
        guard let myProfileVC = self.myProfileVC else {return false}
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        let newVC = PostsCarouselCollectionVC(collectionViewLayout: flowLayout, videoDataList: self.videoDataList, startingIndexPath: indexPath)
        
        
//        newVC.view.layoutIfNeeded()
//        newVC.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        newVC.view.layoutIfNeeded()
        newVC.collectionView.setContentOffset(CGPoint(x: .zero, y: (myProfileVC.view.frame.height - myProfileVC.tabBarController!.tabBar.frame.height) * CGFloat(indexPath.row)), animated: false)
        
        
        
        
        self.myProfileVC?.navigationController?.pushViewController(newVC, animated: true)
        return false
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // push view controller with swipe collectionview
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        let newVC = PostsCarouselCollectionVC(collectionViewLayout: flowLayout, parentCollectionView: self, startingIndexPath: indexPath)
        
        
        newVC.view.layoutIfNeeded()
        newVC.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        
        
        
        
        self.myProfileView?.navigationController?.pushViewController(newVC, animated: true)
        return false
    }
    */
    
    
    
    
    
    
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



