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



class MyProfileVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    
    var currentProfileData: NSMutableDictionary? {
        didSet {
            self.profileHeaderView.currentProfileData = self.currentProfileData
            guard let curProfileData = self.currentProfileData,
                let cur_id = curProfileData["creator_id"] as? String else {
                // handle exit condition here ...
                return;
            }
            if let signed_in_id = appDelegate.currentUserAccount.value(forKey: "signed_in") as? String {
                if signed_in_id == cur_id {
                    if self.profileDisplayStatus != .signedIn {
                        self.profileDisplayStatus = .signedIn
                    }
                } 
            }
           
           
        }
    }
    
   
    
    var profileDisplayStatus : profileDisplayType = .notSignedIn {
        didSet {
            if self.profileDisplayStatus == .notSignedIn {
                self.profileHeaderView.profileDisplayStatus = .notSignedIn
                
                
            } else if self.profileDisplayStatus == .signedIn {
                self.profileHeaderView.profileDisplayStatus = .signedIn
                self.fetchMyProfileData()
                
            } else if self.profileDisplayStatus == .following {
                self.profileHeaderView.profileDisplayStatus = .following
                
                
            } else if self.profileDisplayStatus == .notFollowing {
                self.profileHeaderView.profileDisplayStatus = .notFollowing
                
                
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
        
        if let rootVC = self.navigationController?.viewControllers[0] {
            if rootVC != self {
                if appDelegate.currentUserAccount.value(forKey: "signed_in") as! Bool == false {
                    //            profileHeaderView.signInButton.isHidden = false
                    print("USER IS NOT LOGGED IN, DISPLAYING SIGN IN BUTTON")
                }else{
                    //            profileHeaderView.signInButton.isHidden = true
                    print("USER IS SIGNED IN")
                    if self.profileDisplayStatus == .notSignedIn {
                        self.profileDisplayStatus = .signedIn
                    }
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
        
        
//        profileHeaderView.fetchMyProfile()
        
        profileScrollView.refreshControl = UIRefreshControl()
        profileScrollView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        profileScrollView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        profileScrollView.refreshControl!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        profileScrollView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        profileScrollView.contentInsetAdjustmentBehavior = .never
        
        profileHeaderView.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImgTap)))
        
        
        
        
        self.profileScrollView.addSubview(collectionTabs)
        collectionTabs.translatesAutoresizingMaskIntoConstraints = false
        collectionTabs.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionTabs.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionTabs.topAnchor.constraint(equalTo: profileHeaderView.bottomAnchor).isActive = true
        collectionTabs.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        
        
        
        tabCollectionView.myProfileVC = self
        
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
        
        
//        profileHeaderView.bioTextView.text = "This is my bio...\nIt can be multiple lines and take up the full space."
//        profileHeaderView.profileDisplayStatus = .notSignedIn
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addContextObserver()
        /*
        if appDelegate.currentUserAccount.value(forKey: "signed_in") as! Bool == false {
            //            profileHeaderView.signInButton.isHidden = false
            print("USER IS NOT LOGGED IN, DISPLAYING SIGN IN BUTTON")
        }else{
            //            profileHeaderView.signInButton.isHidden = true
            print("USER IS SIGNED IN")
            if self.profileDisplayStatus == .notSignedIn {
                self.profileDisplayStatus = .signedIn
            }
        }
        */
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
                    self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
                }
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //We replace the interactive popGesture delegate that was there before.
        self.removeContextObserver()
        if let prevDel = previousInteractivePopGestureDelegate {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = prevDel
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
//            self.profileHeaderView.fetchMyProfile()
            self.tabCollectionView.reloadData()
            self.profileScrollView.refreshControl?.endRefreshing()
        }
 
    }
    
    

    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    // UIImagePickerControllerDelegate //////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    @objc func handleProfileImgTap(tapGesture: UITapGestureRecognizer) {
        if !appDelegate.triggerSignInIfNoAccount(customMessgae: "Sign in to create a profile photo") {
            return
        }
        let profileImgActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        profileImgActionSheet.addAction(UIAlertAction(title: "Remove Current Image", style: .destructive, handler:
            { _ in
                // Delete current image
                
        }
        ))
        profileImgActionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler:
            {_ in
                // popCamera taking view
                self.imgFromCamera()
        }
        ))
        profileImgActionSheet.addAction(UIAlertAction(title: "Choose From Photos", style: .default, handler:
            { _ in
                // pop photo library
                self.imgFromPhotos()
        }
        ))
        profileImgActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:
            { _ in
                //closes the action sheet.
        }
        ))
        
        self.present(profileImgActionSheet, animated: true, completion: nil)
    }
    
    func imgFromCamera() {
        let myPickerController = UIImagePickerController()
        myPickerController.allowsEditing = true
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.camera
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func imgFromPhotos() {
        
        let myPickerController = UIImagePickerController()
        myPickerController.allowsEditing = true
        //        myPickerController.preferredContentSize = CGSize(width: 100, height: 100)
        
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            sendProfilePicToServer(newImg: img)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // NETWORKING FUNCTIONS //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    func fetchMyProfileData() {
        
        let url = URL(string: FlykConfig.mainEndpoint + "/myProfile")!
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
            
            do {
                if let myProfileData : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    self.currentProfileData = myProfileData.mutableCopy() as? NSMutableDictionary
                }
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            
            }.resume()
    }
    
    
    
    
    
    func sendProfilePicToServer(newImg : UIImage) {
        
        
        let endPointURL = FlykConfig.uploadEndpoint+"/upload/profilePhoto"
        
        let dataOpt: Data? = newImg.jpegData(compressionQuality: 1)
        guard let dataNotConverted = dataOpt else { return }
        let data = NSData(data: dataNotConverted)
        
        
        let boundary = "?????"
        var request = URLRequest(url: URL(string: endPointURL)!)
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.httpBody = MultiPartPost_2.photoDataToFormData(data: data, boundary: boundary, fileName: "profilePhoto") as Data
        request.addValue("multipart/form-data;boundary=\"" + boundary+"\"",
                         forHTTPHeaderField: "Content-Type")
        request.addValue("image/jpeg", forHTTPHeaderField: "mimeType")
        request.addValue(String((request.httpBody! as NSData).length), forHTTPHeaderField: "Content-Length")
        
        request.addValue("text/plain", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            print(data, response)
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
                print("Server error!")
                //                    print(data, response, error)
                return
            }
            DispatchQueue.main.async {
//                self.profileHeaderView.fetchMyProfile()
            }
            print("SUCCESS")
        }
        
        print("Upload Started")
        task.resume()
        
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    // OBSERVERS ////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    var contextObserverObj: NSObjectProtocol?
    func addContextObserver() {
        self.contextObserverObj = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context, queue: .main){ [unowned self] notification in
            //Add Actions to do when context changes....
            if self.profileDisplayStatus == .notSignedIn {
                if self.appDelegate.currentUserAccount.value(forKey: "signed_in") as! Bool == true {
                    self.profileDisplayStatus = .signedIn
                }
            } else if self.profileDisplayStatus == .signedIn {
                if self.appDelegate.currentUserAccount.value(forKey: "signed_in") as! Bool == false {
                    self.profileDisplayStatus = .notSignedIn
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
