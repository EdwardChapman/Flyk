//
//  VideoBlockCollectionView.swift
//  Flyk
//
//  Created by Edward Chapman on 7/26/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//
/*
import UIKit
import AVFoundation

class VideoBlockCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    
    
    
    var profileImage: UIImageView!
    var videoScrollView : UIScrollView!
    var usernameTextView : UITextView!
    var bioTextView : UITextView!
    
    
    
    
    init(cellType: AnyClass){
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        
    
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.5
        flowLayout.minimumInteritemSpacing = 0.5
        

        self.register(cellType, forCellWithReuseIdentifier: "thumbnailVideo")
        self.delegate = self
        self.dataSource = self
        self.contentInsetAdjustmentBehavior = .never
        
        /* THIS NEEDS TO BE MOVED TO SUPER
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        //        collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 2).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        */
        
        
        self.backgroundColor = UIColor.flykLightBlack
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        self.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        self.refreshControl!.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        self.refreshControl!.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
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
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {return 1}
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.section == 0){
            let profileCell = self.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath)
            return profileCell
        }else{
            let cell = self.dequeueReusableCell(withReuseIdentifier: "thumbnailVideo", for: indexPath)
            cell.backgroundColor = .flykMediumGrey
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(indexPath.section == 0) {
            return CGSize(width: self.frame.width, height: self.frame.height/3)
        }else{
            let cellWidth = (self.frame.width/3) - 0.5
            return CGSize(width: cellWidth, height: cellWidth*(16/9))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("DID END DISPLAYING CELL")
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
        
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // NETWORKING CALLS //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    func loadProfileImage(profileImgString: String){
        let pImgURL = URL(string: FlykConfig.mainEndpoint+"/profilePhotos/"+profileImgString)!
        print(pImgURL)
        URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                print(data)
                self.profileImage.image = UIImage(data: data!)
            }
        }).resume()
        
    }
}
*/
