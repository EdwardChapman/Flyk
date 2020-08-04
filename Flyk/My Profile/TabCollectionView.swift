//
//  TabCollectionView.swift
//  Flyk
//
//  Created by Edward Chapman on 7/26/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class TabCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var myProfileView: MyProfile!

    var collectionTabs: UIView! {
        didSet{
            tabScrollBar.backgroundColor = .white
        }
    }
    var tabScrollBarLeadingAnchor: NSLayoutConstraint!
    lazy var tabScrollBar: UIView = {
        let ts = UIView()
        collectionTabs.addSubview(ts)
        ts.translatesAutoresizingMaskIntoConstraints = false
        ts.bottomAnchor.constraint(equalTo: self.collectionTabs.bottomAnchor).isActive = true
        self.tabScrollBarLeadingAnchor = ts.leadingAnchor.constraint(equalTo: self.collectionTabs.leadingAnchor)
        self.tabScrollBarLeadingAnchor.isActive = true
        ts.heightAnchor.constraint(equalToConstant: 5).isActive = true
        ts.widthAnchor.constraint(equalTo: self.collectionTabs.widthAnchor, multiplier: 1/3).isActive = true
        return ts
    }()
    init(frame: CGRect){
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        
        
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "postsCollectionView")
        self.delegate = self
        self.dataSource = self
        self.contentInsetAdjustmentBehavior = .never
        self.isPagingEnabled = true
        
        self.contentMode = .top
        
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
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = self.dequeueReusableCell(withReuseIdentifier: "postsCollectionView", for: indexPath)
//        for subview in cell.subviews {
//            if let sv = subview as? PostsCollectionView {
//                sv.removeFromSuperview()
//            }
//        }
        let indexColor: [UIColor] = [
            .flykMediumGrey,
            .flykBlue,
            .flykRecordRed
        ]
        cell.backgroundColor = indexColor[indexPath.row]
        
//        cell.translatesAutoresizingMaskIntoConstraints = false
//        cell.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        cell.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
//
        let postsCollectionView = PostsCollectionView(frame: self.frame)
        postsCollectionView.myProfileView = self.myProfileView
        
        cell.addSubview(postsCollectionView)
        postsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        postsCollectionView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
        postsCollectionView.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
        postsCollectionView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        postsCollectionView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
//        postsCollectionView.layoutIfNeeded()
//        postsCollectionView.reloadData()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.frame.size
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
        
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("SCROLL")
        self.tabScrollBarLeadingAnchor.constant = scrollView.contentOffset.x/3
        self.superview?.layoutIfNeeded()
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // NETWORKING CALLS //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    

}

