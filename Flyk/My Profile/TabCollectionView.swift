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
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "draftsCollectionView")
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "likesCollectionView")
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
        
        var cell: UICollectionViewCell!
        var cellCollectionView: UICollectionView!
        
        if indexPath.row == 0 {
            cell = self.dequeueReusableCell(withReuseIdentifier: "postsCollectionView", for: indexPath)
            let postsCollectionView = PostsCollectionView(frame: self.frame )
            postsCollectionView.myProfileView = self.myProfileView
            cellCollectionView = postsCollectionView
        }else if indexPath.row == 1 {
            cell = self.dequeueReusableCell(withReuseIdentifier: "draftsCollectionView", for: indexPath)
            let postsCollectionView = DraftsCollectionView(frame: self.frame )
            postsCollectionView.myProfileView = self.myProfileView
            cellCollectionView = postsCollectionView
        }else if indexPath.row == 2 {
            cell = self.dequeueReusableCell(withReuseIdentifier: "likesCollectionView", for: indexPath)
            let postsCollectionView = PostsCollectionView(frame: self.frame )
            postsCollectionView.myProfileView = self.myProfileView
            cellCollectionView = postsCollectionView
        }

        
        cell.addSubview(cellCollectionView)
        
        cellCollectionView.translatesAutoresizingMaskIntoConstraints = false
        cellCollectionView.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
        cellCollectionView.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
        cellCollectionView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        cellCollectionView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
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

