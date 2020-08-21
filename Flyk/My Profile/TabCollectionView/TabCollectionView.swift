//
//  TabCollectionView.swift
//  Flyk
//
//  Created by Edward Chapman on 7/26/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class TabCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    weak var myProfileVC: MyProfileVC?

    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        self.backgroundColor = .flykLightBlack
        
        
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
    
    let cellIdentifierList = [
        "postsCollectionView",
        "draftsCollectionView",
        "likesCollectionView"
    ]
    
    lazy var collectionViewsList: [UICollectionView] = {
        
        let p = PostsCollectionView(frame: .zero )
        let d = DraftsCollectionView(frame: .zero )
        let l = LikesCollectionView(frame: .zero )

        p.myProfileVC = self.myProfileVC
        d.myProfileVC = self.myProfileVC
        l.myProfileVC = self.myProfileVC
        return [p, d, l]
    }()
    
    
    
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
        
        var cell: UICollectionViewCell = self.dequeueReusableCell(withReuseIdentifier: cellIdentifierList[indexPath.row], for: indexPath)
        var cellCollectionView: UICollectionView = collectionViewsList[indexPath.row]
        cellCollectionView.reloadData()
        
        
//        if indexPath.row == 0 {
//            cell = self.dequeueReusableCell(withReuseIdentifier: "postsCollectionView", for: indexPath)
//            let postsCollectionView = PostsCollectionView(frame: self.frame )
//            postsCollectionView.myProfileVC = self.myProfileVC
//            cellCollectionView = postsCollectionView
//        }else if indexPath.row == 1 {
//            cell = self.dequeueReusableCell(withReuseIdentifier: "draftsCollectionView", for: indexPath)
//            let postsCollectionView = DraftsCollectionView(frame: self.frame )
//            postsCollectionView.myProfileVC = self.myProfileVC
//            cellCollectionView = postsCollectionView
//        }else if indexPath.row == 2 {
//            cell = self.dequeueReusableCell(withReuseIdentifier: "likesCollectionView", for: indexPath)
//            let postsCollectionView = LikesCollectionView(frame: self.frame )
//            postsCollectionView.myProfileVC = self.myProfileVC
//            cellCollectionView = postsCollectionView
//        }

        
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
        self.myProfileVC?.tabScrollBarLeadingAnchor.constant = scrollView.contentOffset.x/3
        self.superview?.layoutIfNeeded()
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // NETWORKING CALLS //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    

}

