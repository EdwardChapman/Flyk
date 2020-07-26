//
//  FifthViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit



class MyProfile: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var profileImage: UIImageView!
    var videoScrollView : UIScrollView!
    var usernameTextView : UITextView!
    var bioTextView : UITextView!
    

    
    func getMyProfile() {
        
        URLSession.shared.dataTask(with: URL(string: "https://swiftytest.uc.r.appspot.com/myProfile/")!) { data, response, error in
            
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
            
            do {
                let myProfileData : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                //            {
                //                username: "Mr. Polar Bear",
                //                profile_photos: "polar_bear.jpg",
                //                videos: [
                //                "v09044e20000brmcq2ihl9acefv17icg.MP4",
                //                "v09044fa0000brfud6gpfrijil1melq0.MP4"
                //                ],
                //                bio: "I am a polar bear."
                //            }
                print(myProfileData)
                
                self.loadProfileImage(profileImgString: myProfileData["profile_photos"] as? String ?? "default.png")
                
                DispatchQueue.main.async {
                    self.usernameTextView.text = myProfileData["username"] as? String
                    self.bioTextView.text = myProfileData["bio"] as? String
                }
                
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            
            }.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.5
        flowLayout.minimumInteritemSpacing = 0.5
        
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: "profileCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "thumbnailVideo")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never
        self.view.addSubview(collectionView)
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//        collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 2).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        
        self.view.backgroundColor = UIColor.flykDarkGrey
        collectionView.backgroundColor = UIColor.flykLightBlack
        
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        collectionView.refreshControl!.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 10).isActive = true
        collectionView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        
    }
    
    
    
    @objc func handleRefreshControl() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
//        fetchVideoList()
        // Dismiss the refresh control.
        DispatchQueue.main.async { self.collectionView.refreshControl!.endRefreshing() }
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
            let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath)
            return profileCell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailVideo", for: indexPath)
            cell.backgroundColor = .flykMediumGrey
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(indexPath.section == 0) {
            return CGSize(width: self.view.frame.width, height: self.view.frame.height/3)
        }else{
            let cellWidth = (self.collectionView.frame.width/3) - 0.5
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
        let pImgURL = URL(string: "https://swiftytest.uc.r.appspot.com/profilePhotos/"+profileImgString)!
        print(pImgURL)
        URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                print(data)
                self.profileImage.image = UIImage(data: data!)
            }
        }).resume()
        
    }
}
