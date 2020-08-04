//
//  PostsCollectionView.swift
//  Flyk
//
//  Created by Edward Chapman on 8/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class PostsCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var myProfileView: MyProfile!
    
    init(frame: CGRect){
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        
        
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        
        self.backgroundColor = .flykDarkGrey
        
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
        return 23
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.dequeueReusableCell(withReuseIdentifier: "postsCollectionView", for: indexPath)
        let indexColor: [UIColor] = [
            .flykDarkWhite,
            .flykBlue,
            .flykRecordRed,
            .flykLightDarkGrey
        ]
        cell.backgroundColor = indexColor[indexPath.row % 4]
        
        
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
        
        let profileScrollView = self.myProfileView.profileScrollView
        
        let pSvHeight = profileScrollView.frame.height
        
        //This is a down drag
        let maxOffset = self.myProfileView.profileView.frame.height - self.myProfileView.view.safeAreaInsets.top
        
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


