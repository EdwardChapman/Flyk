//
//  FifthViewController.swift
//  Flyk
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation



class MyProfileVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    
    var currentProfileData: NSMutableDictionary? {
        didSet {
            self.profileHeaderView.currentProfileData = self.currentProfileData
            
            // check if creator_id exists else undetermined.
            // check for
            // is_followed_by_viewer
            // username
            // profile_bio
            // profile_img_filename
            // else fetch user data...
            guard let curProfileData = self.currentProfileData,
                let cur_id = curProfileData["user_id"] as? String else {
                    // handle exit condition here ...
                    // Keep profile as undetermined...
                    print(self.profileDisplayStatus)
                    if appDelegate.currentUserAccount.value(forKey: "signed_in") as? Bool == true &&
                        self.profileDisplayStatus == .notSignedIn {
                        self.setProfileStatus = .signedIn
                    } else {
                        print("user_id is not defined. Profile is undetermined")
                        if self.profileDisplayStatus != .notSignedIn
                            && self.profileDisplayStatus != .signedIn {
                            print("SETTING UNDETERMINED")
                            self.setProfileStatus = .undetermined
                        }
                    }
                    return;
            }
            
            if appDelegate.currentUserAccount.value(forKey: "signed_in") as? Bool == true {
                if (appDelegate.currentUserAccount.value(forKey: "user_id") as? String) == cur_id {
                    // MY ACCOUNT
                    self.setProfileStatus = .signedIn
                } else { // NOT MY ACCOUNT
                    if curProfileData["is_followed_by_viewer"] as? Bool == true {
                        self.setProfileStatus = .following
                    } else {
                        self.setProfileStatus = .notFollowing
                    }
                }
                
            } else {
                self.setProfileStatus = .notFollowing
            }
        }
    }
    
    
    var setProfileStatus: profileDisplayType {
        set {
            if self.profileDisplayStatus != newValue {
                self.profileDisplayStatus = newValue
            }
        }
        get { return self.profileDisplayStatus }
    }
   
    
    var previousProfileDisplayStatus: profileDisplayType?
    
    var profileDisplayStatus : profileDisplayType = .undetermined {
        willSet {
            self.previousProfileDisplayStatus = self.profileDisplayStatus
        }
        didSet {
            self.profileHeaderView.profileDisplayStatus = self.profileDisplayStatus
            self.tabCollectionView.myProfileVC = self
            self.tabCollectionView.profileDisplayStatus = self.profileDisplayStatus
            
            if self.profileDisplayStatus == .notSignedIn {
                
                // Do nothing b/c we shouldn't have any data
                // set posts, drafts, likes to [] then reload collectionviews
                
            } else if self.profileDisplayStatus == .signedIn {
                // Fetch posts, drafts, likes
                if let prevStatus = self.previousProfileDisplayStatus {
                    if prevStatus == .notSignedIn {
                        fetchMyProfileData()
                    }
                }
                
            } else if self.profileDisplayStatus == .following {
                // Fetch Posts
                // Set drafts, likes to [] then reload collectionview
                
                
            } else if self.profileDisplayStatus == .notFollowing {
                // Fetch Posts
                // Set drafts, likes to [] then reload collectionview
            }
        }
    }
    

    
    

    //CORE DATA
    lazy var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    lazy var context = appDelegate.persistentContainer.viewContext
    
    
    
    
    let profileScrollView = UIScrollView()
    var tabCollectionView: TabCollectionView = TabCollectionView(frame: .zero)
    var profileHeaderView: ProfileHeaderView = ProfileHeaderView(frame: .zero)
    
    //This is so we programatically navigate to drafts
    let draftsTab = UIView()
    var shouldGoToDrafts = false
    
    
    var tabScrollBarLeadingAnchor: NSLayoutConstraint!
    
    lazy var collectionTabs: UIView = {
        let collectionTabs = UIView()
        
        let tabsTopBorder = UIView()
        tabsTopBorder.alpha = 0.1
        collectionTabs.addSubview(tabsTopBorder)
        tabsTopBorder.backgroundColor = .flykDarkWhite
        tabsTopBorder.translatesAutoresizingMaskIntoConstraints = false
        tabsTopBorder.topAnchor.constraint(equalTo: collectionTabs.topAnchor).isActive = true
        tabsTopBorder.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        tabsTopBorder.leadingAnchor.constraint(equalTo: collectionTabs.leadingAnchor).isActive = true
        tabsTopBorder.trailingAnchor.constraint(equalTo: collectionTabs.trailingAnchor).isActive = true
        
        let postsTab = UIView()
        postsTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTabTap(tapGesture:))))
        collectionTabs.addSubview(postsTab)
        postsTab.translatesAutoresizingMaskIntoConstraints = false
        postsTab.leadingAnchor.constraint(equalTo: collectionTabs.leadingAnchor).isActive = true
        postsTab.topAnchor.constraint(equalTo: collectionTabs.topAnchor).isActive = true
        postsTab.bottomAnchor.constraint(equalTo: collectionTabs.bottomAnchor).isActive = true
        postsTab.widthAnchor.constraint(equalTo: collectionTabs.widthAnchor, multiplier: 1/3).isActive = true
        
        let postsImageView = UIImageView(image: UIImage(named: "newCubesV1"))
        postsTab.addSubview(postsImageView)
        postsImageView.contentMode = .scaleAspectFit
        postsImageView.translatesAutoresizingMaskIntoConstraints = false
        postsImageView.centerXAnchor.constraint(equalTo: postsTab.centerXAnchor).isActive = true
        postsImageView.centerYAnchor.constraint(equalTo: postsTab.centerYAnchor).isActive = true
        postsImageView.heightAnchor.constraint(equalTo: postsTab.heightAnchor, multiplier: 0.5).isActive = true
        postsImageView.widthAnchor.constraint(equalTo: postsImageView.widthAnchor).isActive = true
        
        
        draftsTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTabTap(tapGesture:))))
        collectionTabs.addSubview(draftsTab)
        draftsTab.translatesAutoresizingMaskIntoConstraints = false
        draftsTab.leadingAnchor.constraint(equalTo: postsTab.trailingAnchor).isActive = true
        draftsTab.topAnchor.constraint(equalTo: collectionTabs.topAnchor).isActive = true
        draftsTab.bottomAnchor.constraint(equalTo: collectionTabs.bottomAnchor).isActive = true
        draftsTab.widthAnchor.constraint(equalTo: collectionTabs.widthAnchor, multiplier: 1/3).isActive = true
        
        let draftsImageView = UIImageView(image: UIImage(named: "newDraftLockWrenchV1"))
        draftsTab.addSubview(draftsImageView)
        draftsImageView.contentMode = .scaleAspectFit
        draftsImageView.translatesAutoresizingMaskIntoConstraints = false
        draftsImageView.centerXAnchor.constraint(equalTo: draftsTab.centerXAnchor).isActive = true
        draftsImageView.centerYAnchor.constraint(equalTo: draftsTab.centerYAnchor).isActive = true
        draftsImageView.heightAnchor.constraint(equalTo: draftsTab.heightAnchor, multiplier: 0.5).isActive = true
        draftsImageView.widthAnchor.constraint(equalTo: draftsImageView.widthAnchor).isActive = true
        
        
        let likesTab = UIView()
        likesTab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTabTap(tapGesture:))))
        collectionTabs.addSubview(likesTab)
        likesTab.translatesAutoresizingMaskIntoConstraints = false
        likesTab.leadingAnchor.constraint(equalTo: draftsTab.trailingAnchor).isActive = true
        likesTab.topAnchor.constraint(equalTo: collectionTabs.topAnchor).isActive = true
        likesTab.bottomAnchor.constraint(equalTo: collectionTabs.bottomAnchor).isActive = true
        likesTab.widthAnchor.constraint(equalTo: collectionTabs.widthAnchor, multiplier: 1/3).isActive = true
        
        let likesImageView = UIImageView(image: UIImage(named: "newHeartV5"))
        likesTab.addSubview(likesImageView)
        likesImageView.contentMode = .scaleAspectFit
        likesImageView.translatesAutoresizingMaskIntoConstraints = false
        likesImageView.centerXAnchor.constraint(equalTo: likesTab.centerXAnchor).isActive = true
        likesImageView.centerYAnchor.constraint(equalTo: likesTab.centerYAnchor).isActive = true
        likesImageView.heightAnchor.constraint(equalTo: likesTab.heightAnchor, multiplier: 0.5).isActive = true
        likesImageView.widthAnchor.constraint(equalTo: likesImageView.widthAnchor).isActive = true
        
        
        let ts = UIView()
        ts.backgroundColor = .white
        collectionTabs.addSubview(ts)
        ts.translatesAutoresizingMaskIntoConstraints = false
        ts.bottomAnchor.constraint(equalTo: collectionTabs.bottomAnchor).isActive = true
        self.tabScrollBarLeadingAnchor = ts.leadingAnchor.constraint(equalTo: collectionTabs.leadingAnchor)
        self.tabScrollBarLeadingAnchor.isActive = true
        ts.heightAnchor.constraint(equalToConstant: 5).isActive = true
        ts.widthAnchor.constraint(equalTo: collectionTabs.widthAnchor, multiplier: 1/3).isActive = true
        
        
        
        return collectionTabs
    }()
    
    
    

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
            we set the profileVC for tabCollectionview to give it access to the user_id within our userDataDictionary. viewDidLoad seems to happen after the above didset, so this is pretty pointless as we also set it during the didset.
        */
        tabCollectionView.myProfileVC = self
//        print("tabColView.mYProfileVC = self")
        if let rootVC = self.navigationController?.viewControllers[0] {
            if rootVC == self { //If we are the rootVC we are the data source.
                self.profileHeaderView.settingsImgView.isHidden = false
                if appDelegate.currentUserAccount.value(forKey: "signed_in") as? Bool == true {
                    //            profileHeaderView.signInButton.isHidden = false
                    print("USER IS SIGNED IN")
                    self.setProfileStatus = .signedIn
                    
                }else{
                    //            profileHeaderView.signInButton.isHidden = true
                    print("USER IS NOT LOGGED IN, DISPLAYING SIGN IN BUTTON")
                    self.setProfileStatus = .notSignedIn
                }
            }
        }
        // IF WE ARE NOT ROOT VC WE DO NOTHING... THE DID SET WILL FETCH THE INFO WE WANT...
        
        
        self.view.backgroundColor = .flykLightBlack
        self.view.addSubview(profileScrollView)
        profileScrollView.translatesAutoresizingMaskIntoConstraints = false
        profileScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        profileScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        profileScrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        profileScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
        profileScrollView.addSubview(profileHeaderView)
        
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        profileHeaderView.leadingAnchor.constraint(equalTo: profileScrollView.leadingAnchor).isActive = true
        profileHeaderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        profileHeaderView.heightAnchor.constraint(greaterThanOrEqualToConstant: self.view.frame.height/3).isActive = true
        profileHeaderView.topAnchor.constraint(equalTo: profileScrollView.topAnchor, constant: 0).isActive = true
        
        

        
        profileScrollView.refreshControl = UIRefreshControl()
        profileScrollView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        profileScrollView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        profileScrollView.refreshControl!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        profileScrollView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        profileScrollView.contentInsetAdjustmentBehavior = .never
        

        
        
        
        
        self.profileScrollView.addSubview(collectionTabs)
        collectionTabs.translatesAutoresizingMaskIntoConstraints = false
        collectionTabs.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionTabs.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionTabs.topAnchor.constraint(equalTo: profileHeaderView.bottomAnchor).isActive = true
        collectionTabs.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        
        
        
        
        
        self.profileScrollView.addSubview(tabCollectionView)
        self.view.layoutIfNeeded()
        tabCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tabCollectionView.leadingAnchor.constraint(equalTo: self.profileScrollView.leadingAnchor).isActive = true
//        tabCollectionView.trailingAnchor.constraint(equalTo: self.profileScrollView.trailingAnchor).isActive = true
        tabCollectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        tabCollectionView.topAnchor.constraint(equalTo: collectionTabs.bottomAnchor).isActive = true
        tabCollectionView.heightAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.heightAnchor, constant: -45).isActive = true
        
        let tabColViewHeightAnchor = tabCollectionView.heightAnchor.constraint(equalToConstant: 1000)
        tabColViewHeightAnchor.priority = UILayoutPriority(999)
        tabColViewHeightAnchor.isActive = true
        self.view.layoutIfNeeded()
        tabCollectionView.reloadData()
        
        let tabColViewHeight = tabCollectionView.frame.height
        let colTabsHeight = collectionTabs.frame.height
        let profileViewHeight = profileHeaderView.frame.height
        
        
        self.profileScrollView.contentSize = CGSize(
            width: self.view.frame.width,
            height: tabColViewHeight+colTabsHeight+profileViewHeight-45
        )

        profileHeaderView.settingsImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSettingsTap(tapGesture:))))
        
        

        
        
        self.profileHeaderView.followButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleToggleFollow(tapGesture:))))
        self.profileHeaderView.followingButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleToggleFollow(tapGesture:))))
        
        self.profileHeaderView.editProfileButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEditProfileTap(tapGesture:))))
        
        
    }
    
    @objc func handleToggleFollow(tapGesture: UITapGestureRecognizer) {
        print("TOGGLE FOLLOW")
        
        let msg = "Sign in to follow\n" + ((self.currentProfileData?["username"] as? String) ?? "user")
        if self.appDelegate.triggerSignInIfNoAccount(customMessgae: msg) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            if self.profileDisplayStatus == .notFollowing {
                print("Follow")
//                self.isVideoLiked = true
                
                let videoListURL = URL(string: FlykConfig.mainEndpoint+"/user/follow")!
                
                var request = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let parameters: NSDictionary = ["userId": self.currentProfileData?["user_id"]]
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch let error {
                    print(error.localizedDescription)
                    return;
                }
                
                
                request.httpMethod = "POST"
                URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    if error != nil {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
//                        self.isVideoLiked = false
                        return
                    }
                    guard let response = response as? HTTPURLResponse else {
                        print("not httpurlresponse...!")
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                        return;
                    }
                    
                    if(response.statusCode == 200) {
                        DispatchQueue.main.async {
                            if let curProfData = self.currentProfileData {
                                curProfData["is_followed_by_viewer"] = true
                                self.currentProfileData = curProfData
                            }
                        }
                        //Worked....
                    }else{
                        print("Response not 200", response)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
//                        self.isVideoLiked = false
                    }
                    
                    }.resume()
                
            } else if self.profileDisplayStatus == .following {
                print("Following")
                
//                self.isVideoLiked = false
                
                let videoListURL = URL(string: FlykConfig.mainEndpoint+"/user/unfollow")!
                
                var request = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                 let parameters: NSDictionary = ["userId": self.currentProfileData?["user_id"]]
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch let error {
                    print(error.localizedDescription)
                    return;
                }
                
                
                request.httpMethod = "POST"
                URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    if error != nil {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
//                        self.isVideoLiked = true
                        return
                    }
                    guard let response = response as? HTTPURLResponse else {
                        print("not httpurlresponse...!")
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                        return;
                    }
                    
                    if(response.statusCode == 200) {
                        //Worked....
                        DispatchQueue.main.async {
                            if let curProfData = self.currentProfileData {
                                curProfData["is_followed_by_viewer"] = false
                                self.currentProfileData = curProfData
                            }
                        }
                    }else{
                        print("Response not 200", response)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
//                        self.isVideoLiked = true
                    }
                    
                    }.resume()
            

            }
        }
    }
    @objc func handleEditProfileTap(tapGesture: UITapGestureRecognizer) {
        
        
        let editProfileNavVC = EditProfileNavController()
        editProfileNavVC.transitioningDelegate = editProfileNavVC
        editProfileNavVC.modalPresentationStyle = .custom
        editProfileNavVC.editProfileRootVC.myProfileVC = self
        self.present(editProfileNavVC, animated: true, completion: {})
        
        
//        let vc = EditProfileVC()
//        vc.myProfileVC = self
//        self.present(vc, animated: true) {
//
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addContextObserver()
        
        if self.profileDisplayStatus == .signedIn {
            self.fetchMyProfileData()
        } else if self.profileDisplayStatus == .following
            || self.profileDisplayStatus == .notFollowing {
            self.fetchProfileByUserId()
        }
        
//        if self.appDelegate.currentUserAccount.value(forKey: "signed_in") as! Bool == true {
//            print("USER IS SIGNED IN")
//            if self.profileDisplayStatus == .notSignedIn {
//                self.setProfileStatus = .signedIn
//            }
//        }else{
//            print("USER IS NOT LOGGED IN, DISPLAYING SIGN IN BUTTON")
//            if self.profileDisplayStatus == .signedIn {
//                self.setProfileStatus = .notSignedIn
//            } else if self.profileDisplayStatus == .following {
//                self.setProfileStatus = .notFollowing
//            }
//        }
        if self.profileDisplayStatus != .undetermined {
            let c = self.currentProfileData
            self.currentProfileData = c
        }
        
 
    }
    
    var previousInteractivePopGestureDelegate: UIGestureRecognizerDelegate?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(shouldGoToDrafts){
            goToDrafts()
            print("RELOAD DRAFTS HERE")
        }
        
        //We store the navigation controllers interactive pop delegate before removing it
        //We will place it back during viewWillDissappear
        if animated {
            if let rootVC = self.navigationController?.viewControllers[0] {
                if rootVC != self {
                    previousInteractivePopGestureDelegate = self.navigationController?.interactivePopGestureRecognizer?.delegate
                    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
                }
            }
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //We replace the interactive popGesture delegate that was there before.
        self.removeContextObserver()
        if animated {
            if let prevDel = previousInteractivePopGestureDelegate {
                self.navigationController?.interactivePopGestureRecognizer?.delegate = prevDel
            }
        }
    }
    
    
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Gesture Handling Functions //////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    @objc func handleSettingsTap(tapGesture: UITapGestureRecognizer) {
        self.navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
    @objc func handleTabTap(tapGesture: UITapGestureRecognizer) {
        let scrollToX = (tapGesture.view?.frame.minX)! * 3
        self.tabCollectionView.setContentOffset(CGPoint(x: scrollToX, y: 0), animated: true)
    }
    func goToDrafts() {
        tabCollectionView.reloadData()
        let scrollToX = self.draftsTab.frame.minX * 3
        self.tabCollectionView.setContentOffset(CGPoint(x: scrollToX, y: 0), animated: true)
        self.shouldGoToDrafts = false
        //Reload tab
    }
    
    
    
    @objc func handleRefreshControl() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        DispatchQueue.main.async {
            //This function will dismiss the refresh control

            if self.profileDisplayStatus == .signedIn {
                self.fetchMyProfileData()
            } else if self.profileDisplayStatus == .following
                || self.profileDisplayStatus == .notFollowing {
                self.fetchProfileByUserId()
            }
            self.tabCollectionView.profileDisplayStatus = self.profileDisplayStatus
//            self.profileScrollView.refreshControl?.endRefreshing()
        }
 
    }
    
    

    
    
    
    
    
    
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // NETWORKING FUNCTIONS //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    func fetchMyProfileData() {
        print("Fetching profile data")
        let url = URL(string: FlykConfig.mainEndpoint + "/myProfile")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.profileScrollView.refreshControl?.endRefreshing()
            }
            
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
                if let myProfileData : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let c = self.currentProfileData {
                        if let keys = myProfileData.allKeys as? [String] {
                            for key in keys {
                                c[key] = myProfileData[key]
                            }
                        }
                        self.currentProfileData = c
                    } else {
                        self.currentProfileData = myProfileData.mutableCopy() as? NSMutableDictionary
                    }
                }
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            
        }.resume()
    }
    
    func fetchProfileByUserId() {
        print("Fetching profile data")
        
        let videoListURL = URL(string: FlykConfig.mainEndpoint+"/user")!
        
        var request = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: NSDictionary = ["userId": self.currentProfileData?["user_id"]]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch let error {
            print(error.localizedDescription)
            return;
        }
        
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.profileScrollView.refreshControl?.endRefreshing()
            }
            
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
                if let myProfileData : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    if let c = self.currentProfileData {
                        if let keys = myProfileData.allKeys as? [String] {
                            for key in keys {
                                c[key] = myProfileData[key]
                            }
                        }
                        self.currentProfileData = c
                    } else {
                        self.currentProfileData = myProfileData.mutableCopy() as? NSMutableDictionary
                    }
                }
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            
        }.resume()
    }
    
    
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    // OBSERVERS ////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    var contextObserverObj: NSObjectProtocol?
    func addContextObserver() {
        self.contextObserverObj = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context, queue: .main){ [unowned self] notification in
            
            guard let userInfo = notification.userInfo else { return }
            
            if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0
            {
                if updates.first?.entity.name == "Accounts" {
                    //Add Actions to do when context changes....
                    if self.profileDisplayStatus != .undetermined {
                        let c = self.currentProfileData
                        self.currentProfileData = c
                    }
                }
            }
        }
    }
    func removeContextObserver() {
        if let obs = self.contextObserverObj {
            NotificationCenter.default.removeObserver(obs)
            self.contextObserverObj = nil
        }
    }
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    //SubCollectionView Data ////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
}
