//
//  FifthViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation



class MyProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var profileImage: UIImageView!
    var videoScrollView : UIScrollView!
    var usernameTextView : UITextView!
    var bioTextView : UITextView!
    
    
    
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    
    
    lazy var savedVideosData: [NSManagedObject] = fetchDraftEntityList()
    
    
    
    func fetchDraftEntityList() -> [NSManagedObject]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Draft")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            return result as! [NSManagedObject]
        } catch {
            print("Failed fetching saved videos", error)
            return []
        }
        //        print(data.entity.attributesByName.keys) //GET ALL KEYS
        //        print(data.value(forKey: "videoUrl") //GET VALUE
    }

    
    let profileScrollView = UIScrollView()
    var tabCollectionView: TabCollectionView!
    var profileHeaderView: ProfileHeaderView!
    let draftsTab = UIView()
    
    var shouldGoToDrafts = false
    

    
    var previousInteractivePopGestureDelegate: UIGestureRecognizerDelegate?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if appDelegate.currentUserAccount.value(forKey: "signed_in") as! Bool == false {
            profileHeaderView.signInButton.isHidden = false
        }else{
            profileHeaderView.signInButton.isHidden = true
        }
        if(shouldGoToDrafts){
            goToDrafts()
        }
        
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
        if let prevDel = previousInteractivePopGestureDelegate {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = prevDel
        }
    }
    
    @objc func handleProfileImgTap(tapGesture: UITapGestureRecognizer){
        let profileImgActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        profileImgActionSheet.addAction(UIAlertAction(title: "Remove Current Image", style: .destructive,
            handler: { _ in
                // Delete current image
            })
        )
        profileImgActionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default,
            handler: { _ in
                // popCamera taking view
                self.imgFromCamera()
            })
        )
        profileImgActionSheet.addAction(UIAlertAction(title: "Choose From Photos", style: .default,
            handler: { _ in
                // pop photo library
                self.imgFromPhotos()
            })
        )
        profileImgActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel,
            handler: { _ in
                //closes the action sheet.
            })
        )
        
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
//            profileHeaderView.profileImageView.image = img
            sendProfilePicToServer(newImg: img)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendProfilePicToServer(newImg : UIImage){
        
        
        let endPointURL = FlykConfig.uploadEndpoint+"/upload/profilePhoto"
        
        let dataOpt: Data? = newImg.jpegData(compressionQuality: 1)
        guard let dataNotConverted = dataOpt else { return }
        let data = NSData(data: dataNotConverted)
        
        
        let boundary = "?????"
        var request = URLRequest(url: URL(string: endPointURL)!)
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.httpBody = MultiPartPost_2.photoDataToFormData(data: data, boundary: boundary, fileName: "profilePhoto") as Data
        //            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.addValue("multipart/form-data;boundary=\"" + boundary+"\"",
                         forHTTPHeaderField: "Content-Type")
        request.addValue("image/jpeg", forHTTPHeaderField: "mimeType")
        request.addValue(String((request.httpBody! as NSData).length), forHTTPHeaderField: "Content-Length")
        
        request.addValue("text/plain", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print(data, response)
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
                self.profileHeaderView.fetchProfileData()
            }
            print("SUCCESS")
        }
        
        print("Upload Started")
        task.resume()
            

    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.view.backgroundColor = .flykLightBlack
        self.view.addSubview(profileScrollView)
        profileScrollView.translatesAutoresizingMaskIntoConstraints = false
        profileScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        profileScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        profileScrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        profileScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        profileHeaderView = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/3))
        profileScrollView.addSubview(profileHeaderView)
        profileHeaderView.fetchProfileData()
        
        profileScrollView.refreshControl = UIRefreshControl()
        profileScrollView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        profileScrollView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        profileScrollView.refreshControl!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        profileScrollView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        profileScrollView.contentInsetAdjustmentBehavior = .never
        
        profileHeaderView.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImgTap)))
        
        
        
        let collectionTabs = UIView()
        self.profileScrollView.addSubview(collectionTabs)
        collectionTabs.translatesAutoresizingMaskIntoConstraints = false
        collectionTabs.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionTabs.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionTabs.topAnchor.constraint(equalTo: profileHeaderView.bottomAnchor).isActive = true
        collectionTabs.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
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
        
        
        tabCollectionView = TabCollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
        tabCollectionView.myProfileView = self
        tabCollectionView.collectionTabs = collectionTabs
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
//        tabCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.view.layoutIfNeeded()
        tabCollectionView.reloadData()
        
        let tabColViewHeight = tabCollectionView.frame.height
        let colTabsHeight = collectionTabs.frame.height
        let profileViewHeight = profileHeaderView.frame.height
        self.profileScrollView.contentSize = CGSize(
            width: self.view.frame.width,
            height: tabColViewHeight+colTabsHeight+profileViewHeight-45
        )
        
//        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        flowLayout.scrollDirection = .vertical
//        flowLayout.minimumLineSpacing = 0.5
//        flowLayout.minimumInteritemSpacing = 0.5
//
//        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: "profileCell")
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "thumbnailVideo")
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.contentInsetAdjustmentBehavior = .never
//        self.view.addSubview(collectionView)
//
//
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
//
//
//        self.view.backgroundColor = UIColor.flykDarkGrey
//        collectionView.backgroundColor = UIColor.flykLightBlack
//
//
//        collectionView.refreshControl = UIRefreshControl()
//        collectionView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
//        collectionView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.refreshControl!.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 10).isActive = true
//        collectionView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        profileHeaderView.settingsImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSettingsTap(tapGesture:))))
        
    }
    
    @objc func handleSettingsTap(tapGesture: UITapGestureRecognizer){
        self.navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
    @objc func handleTabTap(tapGesture: UITapGestureRecognizer){
        let scrollToX = (tapGesture.view?.frame.minX)! * 3
        self.tabCollectionView.setContentOffset(CGPoint(x: scrollToX, y: 0), animated: true)
    }
    func goToDrafts(){
        tabCollectionView.reloadData()
        let scrollToX = self.draftsTab.frame.minX * 3
        self.tabCollectionView.setContentOffset(CGPoint(x: scrollToX, y: 0), animated: true)
        self.shouldGoToDrafts = false
        //Reload tab
    }
    
    
    
    @objc func handleRefreshControl() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
//        fetchVideoList()
        // Dismiss the refresh control.
        
        DispatchQueue.main.async {
//            self.savedVideosData = self.fetchDraftEntityList()
//            self.collectionView.reloadData()
//            self.collectionView.refreshControl!.endRefreshing()
            self.profileScrollView.refreshControl?.endRefreshing()
        }
 
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // COLLECTIONVIEW DELEGATE ///////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {return 1}
        return savedVideosData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.section == 0){
            let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath)
            
            return profileCell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailVideo", for: indexPath)
            cell.backgroundColor = .flykMediumGrey
            
            let savedURL = savedVideosData[indexPath.row].value(forKey: "filename") as! String
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent(savedURL)
            
            
            let videoAsset = AVAsset(url: documentsUrl)
            let newPlayer = AVPlayer(url: documentsUrl)
            let playerLayer = AVPlayerLayer()
            playerLayer.player = newPlayer
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = cell.layer.bounds
            cell.layer.addSublayer(playerLayer)
            
            
            
            let cellOverlay = UIView()
            cell.addSubview(cellOverlay)
            cellOverlay.translatesAutoresizingMaskIntoConstraints = false
            cellOverlay.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
            cellOverlay.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
            cellOverlay.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            cellOverlay.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            
            let uploadProgressView = UIView()
            uploadProgressView.backgroundColor = .flykBlue
            uploadProgressView.alpha = 0.7
            cellOverlay.addSubview(uploadProgressView)
            uploadProgressView.translatesAutoresizingMaskIntoConstraints = false
            let bottomTopAnchor = uploadProgressView.topAnchor.constraint(equalTo: cellOverlay.bottomAnchor)
            bottomTopAnchor.isActive = true
            let topTopAnchor = uploadProgressView.topAnchor.constraint(equalTo: cellOverlay.topAnchor)
            topTopAnchor.isActive = false
            uploadProgressView.bottomAnchor.constraint(equalTo: cellOverlay.bottomAnchor).isActive = true
            uploadProgressView.leadingAnchor.constraint(equalTo: cellOverlay.leadingAnchor).isActive = true
            uploadProgressView.trailingAnchor.constraint(equalTo: cellOverlay.trailingAnchor).isActive = true
            
            let uploadingLabel = UILabel()
            cellOverlay.addSubview(uploadingLabel)
            uploadingLabel.text = "Uploading"
            uploadingLabel.textColor = .white
            uploadingLabel.translatesAutoresizingMaskIntoConstraints = false
            uploadingLabel.centerXAnchor.constraint(equalTo: cellOverlay.centerXAnchor).isActive = true
            uploadingLabel.centerYAnchor.constraint(equalTo: cellOverlay.centerYAnchor).isActive = true
            
            let cancelLabel = UILabel()
            cellOverlay.addSubview(cancelLabel)
            cancelLabel.text = "CANCEL"
            cancelLabel.textColor = .white
            cancelLabel.backgroundColor = .red
            cancelLabel.alpha = 0.7
            cancelLabel.layer.cornerRadius = 5
            cancelLabel.clipsToBounds = true
            cancelLabel.translatesAutoresizingMaskIntoConstraints = false
            cancelLabel.centerXAnchor.constraint(equalTo: cellOverlay.centerXAnchor).isActive = true
            cancelLabel.topAnchor.constraint(equalTo: uploadingLabel.bottomAnchor, constant: 20).isActive = true
            
            cell.layoutIfNeeded()
            
            bottomTopAnchor.isActive = false
            topTopAnchor.isActive = true
            
            UIView.animate(withDuration: 5, animations: {
                cell.layoutIfNeeded()
            }) { (finished) in
                
                uploadingLabel.text = "Processing"
                
                cancelLabel.isHidden = true
                let processingBar = UIView()
                cellOverlay.addSubview(processingBar)
                processingBar.translatesAutoresizingMaskIntoConstraints = false
                processingBar.centerXAnchor.constraint(equalTo: cellOverlay.centerXAnchor).isActive = true
                processingBar.topAnchor.constraint(equalTo: uploadingLabel.bottomAnchor, constant: 15).isActive = true
                processingBar.widthAnchor.constraint(equalTo: cellOverlay.widthAnchor, multiplier: 0.7).isActive = true
                processingBar.heightAnchor.constraint(equalToConstant: 25).isActive = true
                processingBar.layer.cornerRadius = 25/2
                processingBar.backgroundColor = .white
                processingBar.clipsToBounds = true
                cell.layoutIfNeeded()
                var pBStart: CGFloat = -processingBar.frame.width - 35
                var counter = 0
                while(pBStart < processingBar.frame.width){
                    counter+=1
                    let slantBar = UIView()
                    processingBar.addSubview(slantBar)
                    slantBar.backgroundColor = .flykBlue
                    slantBar.frame = CGRect(
                        x: pBStart,
                        y: 0,
                        width: 10,
                        height: processingBar.frame.height*1.5
                    )
                    slantBar.center.y = processingBar.bounds.height/2
                    pBStart += 2*slantBar.frame.width
                    slantBar.transform = slantBar.transform.rotated(by: 3.14*(1/6))
                }
                let posMov: CGFloat = CGFloat((Int(processingBar.frame.width/10)+2)*10)
                for slant in processingBar.subviews {
                    UIView.animate(withDuration: 4, delay: 0, options: [.curveLinear, .repeat], animations: {
                        UIView.setAnimationRepeatCount(1)
                        slant.center.x += posMov
                    }, completion: { (finished) in
//                        print("COMPLETED")
                        if slant == processingBar.subviews.last {
                            UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                                cellOverlay.alpha = 0
                            }, completion: {(fin) in
                                print(fin)
                                cellOverlay.isHidden = true
                            })
                        }
                    })
                }
            }
            
            newPlayer.play()
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
    
    
//    func getMyProfile() {
//        
//        URLSession.shared.dataTask(with: URL(string: FlykConfig.mainEndpoint+"/myProfile/")!) { data, response, error in
//            
//            if error != nil || data == nil {
//                print("Client error!")
//                return
//            }
//            
//            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                print("Server error!")
//                return
//            }
//            
//            guard let mime = response.mimeType, mime == "application/json" else {
//                print("Wrong MIME type!")
//                return
//            }
//            
//            do {
//                let myProfileData : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
//                //            {
//                //                username: "Mr. Polar Bear",
//                //                profile_photos: "polar_bear.jpg",
//                //                videos: [
//                //                "v09044e20000brmcq2ihl9acefv17icg.MP4",
//                //                "v09044fa0000brfud6gpfrijil1melq0.MP4"
//                //                ],
//                //                bio: "I am a polar bear."
//                //            }
//                print(myProfileData)
//                
//                self.loadProfileImage(profileImgString: myProfileData["profile_photos"] as? String ?? "default.png")
//                
//                DispatchQueue.main.async {
//                    self.usernameTextView.text = myProfileData["username"] as? String
//                    self.bioTextView.text = myProfileData["bio"] as? String
//                }
//                
//                
//            } catch {
//                print("JSON error: \(error.localizedDescription)")
//            }
//            
//            }.resume()
//    }
//    
//    func loadProfileImage(profileImgString: String){
//        let pImgURL = URL(string: FlykConfig.mainEndpoint+"/profilePhotos/"+profileImgString)!
//        print(pImgURL)
//        URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
//            DispatchQueue.main.async {
//                print(data)
//                self.profileImage.image = UIImage(data: data!)
//            }
//        }).resume()
//        
//    }
}
