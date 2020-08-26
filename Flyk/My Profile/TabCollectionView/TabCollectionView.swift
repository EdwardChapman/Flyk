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
    
    
    
    
    var profileDisplayStatus : profileDisplayType = .undetermined {
        didSet{
            if self.profileDisplayStatus == .notSignedIn {
                DispatchQueue.main.async {
                    let pcv = (self.collectionViewsList[0] as! PostsCollectionView)
                    let dcv = (self.collectionViewsList[1] as! DraftsCollectionView)
                    let lcv = (self.collectionViewsList[2] as! LikesCollectionView)
                    pcv.videoDataList = []
                    dcv.savedVideosData = dcv.fetchDraftEntityList()
                    lcv.videoDataList = []
                }
            } else if self.profileDisplayStatus == .signedIn {
                DispatchQueue.main.async {
                    self.fetchMyPosts()
                    self.fetchMyLikes()
                    let dcv = (self.collectionViewsList[1] as! DraftsCollectionView)
                    dcv.savedVideosData = dcv.fetchDraftEntityList()
                    
                }
            } else if self.profileDisplayStatus == .following {
                DispatchQueue.main.async {
                    let pcv = (self.collectionViewsList[0] as! PostsCollectionView)
                    let dcv = (self.collectionViewsList[1] as! DraftsCollectionView)
                    let lcv = (self.collectionViewsList[2] as! LikesCollectionView)
                    dcv.savedVideosData = []
                    lcv.videoDataList = []
                    self.fetchMyPostsByUserId()
                }
            } else if self.profileDisplayStatus == .notFollowing {
                DispatchQueue.main.async {
                    let pcv = (self.collectionViewsList[0] as! PostsCollectionView)
                    let dcv = (self.collectionViewsList[1] as! DraftsCollectionView)
                    let lcv = (self.collectionViewsList[2] as! LikesCollectionView)
                    dcv.savedVideosData = []
                    lcv.videoDataList = []
                    self.fetchMyPostsByUserId()
                }
            }
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
    }
    
   

    

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
        
        self.contentInsetAdjustmentBehavior = .never
        
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
//        cellCollectionView.reloadData()
        if let postCells = cellCollectionView.visibleCells as? [PostsCell] {
            for p in postCells {
                p.gifImageView?.startAnimating()
            }
        }
        
        
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
    

    
    func fetchMyPosts() {
        print("FETCHING POSTS HERE")
        let url = URL(string: FlykConfig.mainEndpoint + "/myProfile/posts")!
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
                        
                        let pcv = (self.collectionViewsList[0] as! PostsCollectionView)

                        pcv.videoDataList = videosList.map{ dict -> NSMutableDictionary in dict.mutableCopy() as! NSMutableDictionary}
//                        print(pcv.videoDataList)
                    }
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
            }else{
                print("Response not 200", response)
            }
            
            }.resume()
        
    }
    
    
    
    func fetchMyLikes() {
        print("FETCHING LIKES HERE")
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
                        let lcv = (self.collectionViewsList[2] as! LikesCollectionView)
                        lcv.videoDataList = videosList.map{ dict -> NSMutableDictionary in dict.mutableCopy() as! NSMutableDictionary}
                    }
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
            }else{
                print("Response not 200", response)
            }
            
        }.resume()
        
    }
    
    
    
    func fetchMyPostsByUserId() {
//        print(self.myProfileVC)
        guard let curProfData = self.myProfileVC?.currentProfileData else {
            print("fetchMyPostsGuardFailure")
            return}
        
        
        let videoListURL = URL(string: FlykConfig.mainEndpoint + "/user/posts")!
        var request = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: NSDictionary = ["userId": curProfData["user_id"]]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch let error {
            print(error.localizedDescription)
            return;
        }
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        
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
                        
                        let pcv = (self.collectionViewsList[0] as! PostsCollectionView)
                        
                        pcv.videoDataList = videosList.map{ dict -> NSMutableDictionary in dict.mutableCopy() as! NSMutableDictionary}
//                        print(pcv.videoDataList)
                    } else {
                        print("Couln't fetch user's posts")
                    }
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
            }else{
                print("Response not 200", response)
            }
            
            }.resume()
        
    }
    
    
    
}

