//
//  FirstViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension String {
    func decodeHTML() -> String{
        return self.replacingOccurrences(of: "&amp;", with: "&")
        .replacingOccurrences(of: "&quot;", with: "\"")
        .replacingOccurrences(of: "&#x27", with: "\'")
        .replacingOccurrences(of: "&lt;", with: "<")
        .replacingOccurrences(of: "&gt;", with: ">")
        .replacingOccurrences(of: "&#x2F;", with: "/")
        .replacingOccurrences(of: "&#x5C;", with: "\\")
        .replacingOccurrences(of: "&#96;", with: "`")
    }
}

class Home: UIViewController, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var startingIndex: Int?
    var refreshFunction: ((([NSMutableDictionary]?)->())->())?
    convenience init(
        startingIndex: Int,
        videoDataList: [NSMutableDictionary],
        presentingVC: UIViewController,
        refreshFunction: @escaping (([NSMutableDictionary]?)->())->() ) {
        
        self.init()
        self.startingIndex = startingIndex
        self.refreshFunction = refreshFunction
        self.videosDataList = videoDataList
        self.view.layoutIfNeeded()
        self.collectionView.setContentOffset(
            CGPoint(
                x: .zero,
                y: (presentingVC.view.frame.height - presentingVC.tabBarController!.tabBar.frame.height) * CGFloat(startingIndex)
            ),
            animated: false
        )
        
        
        // Did set not called during init so we need to end this here
        self.collectionView.refreshControl!.endRefreshing()
    }

    
    lazy var collectionView: UICollectionView = {
        let colV = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        let flowLayout = colV.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        colV.register(VideoCell.self, forCellWithReuseIdentifier: "videoCell")
        colV.delegate = self
        colV.dataSource = self
        colV.prefetchDataSource = self
        
        colV.decelerationRate = .fast
        colV.showsVerticalScrollIndicator = false
        colV.showsHorizontalScrollIndicator = false
        
        colV.contentInsetAdjustmentBehavior = .never
        colV.isPagingEnabled = true
        
        
        colV.refreshControl = UIRefreshControl()

        colV.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        colV.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        colV.refreshControl!.topAnchor.constraint(equalTo: colV.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        colV.refreshControl!.centerXAnchor.constraint(equalTo: colV.centerXAnchor).isActive = true
        colV.refreshControl?.beginRefreshing()
        return colV
    }()
    
    
    
    
    
    var videosDataList : [NSMutableDictionary] = [] {
        didSet {
            DispatchQueue.main.async {
                print("_____________\nEND REFRESHING\n_______________")
                self.collectionView.refreshControl!.endRefreshing()
                self.collectionView.reloadData()
            }
        }
    }
    
    var currentCell : VideoCell? {
        didSet {
            guard let curCell = currentCell,
                let cellIndex = collectionView.indexPath(for: curCell)
                else { return }
            if videosDataList.count > 0 && cellIndex.row > (videosDataList.count - 2) {
                print("FETCH NEW ITEMS HERE")
            }
        }
    }
    
    var returnToForegroundObserver: NSObjectProtocol?
    
    lazy var commentsViewController: CommentsViewController = {
        let cVc = CommentsViewController()
        cVc.goToProfileFunction = self.handleGoToProfileTap
        cVc.transitioningDelegate = cVc
        cVc.modalPresentationStyle = .custom
        return cVc
    }()
    
    
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // LIFECYCLE METHODS /////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        

        //FETCH INITIAL DATA
        if let rootVC = self.navigationController?.viewControllers[0] {
            if rootVC == self { //If we are the rootVC we are the data source.
                fetchVideoList()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addReturnToForegroundObserver()
        if let currentCell = self.currentCell {
            if !currentCell.isPaused {
                currentCell.player.play()
            }
        }
    }
    

    var previousInteractivePopGestureDelegate: UIGestureRecognizerDelegate?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //We store the navigation controllers interactive pop delegate before removing it
        //We will place it back during viewWillDissappear
        if animated {
            if let rootVC = self.navigationController?.viewControllers[0] {
                if rootVC != self {
                    self.previousInteractivePopGestureDelegate = self.navigationController?.interactivePopGestureRecognizer?.delegate
                    self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        //We replace the interactive popGesture delegate that was there before.
        if animated {
            if let prevDel = self.previousInteractivePopGestureDelegate {
                self.navigationController?.interactivePopGestureRecognizer?.delegate = prevDel
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeReturnToForegroundObserver()
        if let currentCell = self.currentCell {
            currentCell.player.pause()
        }
    }
    
    deinit {
        removeReturnToForegroundObserver()
        print("deinit")
    }



    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // COLLECTIONVIEW DELEGATE ///////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    //PREFETCH
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Begin asynchronously fetching data for the requested index paths.
/*
        for indexPath in indexPaths {
            let prefetchURL = videosDataList[indexPath.row]["videoFilename"]
//            asyncFetcher.fetchAsync(model.identifier)
            print(indexPath)
            
        }
 */
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videosDataList.count
    }
    
    //
    // THIS CREATES/REUSES CELL
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCell

        cell.setupNewVideo(fromDict: videosDataList[indexPath.row])
        
        cell.profileImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGoToProfileTap(tapGesture:))))
        cell.usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGoToProfileTap(tapGesture:))))
        cell.share.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShareTap(tapGesture:))))
        cell.comments.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCommentsTap(tapGesture:))))
        cell.moreOptions.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMoreOptionsTap(tapGesture:))))
//        cell.player.playImmediately(atRate: 1.0)
        cell.addDidEndObserver()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    



    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height-self.view.safeAreaInsets.bottom)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        let videoCell = cell as! VideoCell
        if self.currentCell == nil
            && (self.startingIndex == nil || self.startingIndex! == indexPath.row){
            self.currentCell = videoCell
            self.currentCell?.isPaused = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    
    
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // SCROLLVIEW DELEGATE ///////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newIndex = collectionView.indexPathForItem(at: scrollView.contentOffset)
        if let newPath = newIndex {
            if let newCell = collectionView.cellForItem(at: newPath){
                let newVideoCell = newCell as! VideoCell
                if self.currentCell !== newVideoCell {
                    self.currentCell!.isPaused = true
                    self.currentCell?.player.seek(to: .zero)
                    self.currentCell = newVideoCell
                    self.currentCell!.isPaused = false
                }
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    

    
    
    ////////////////////////////////////////////////////////////////////////////////////////
    // USER ACTION SELECTOR FUNCTIONS //////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////
    
    @objc func handleMoreOptionsTap(tapGesture: UITapGestureRecognizer){
        let profileImgActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        profileImgActionSheet.addAction(
            UIAlertAction(title: "Delete Video", style: .destructive, handler:
            { _ in
                // Delete current image
                guard let vidCell = tapGesture.view?.superview as? VideoCell,
                    let vidData = vidCell.currentVideoData,
                    let video_id_to_delete = vidData["video_id"] as? String
                else { return }
                
                let url = URL(string: FlykConfig.mainEndpoint + "/video/delete")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                let parameters: NSDictionary = ["videoId": video_id_to_delete]
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch let error {
                    print(error.localizedDescription)
                    return;
                }
                
                
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        
                    }
                    if(error != nil) {return print(error)}
                    guard let response = response as? HTTPURLResponse
                        else{print("resopnse is not httpurlResponse"); return;}
                    print("Status: ", response.statusCode)
                    
                    if response.statusCode == 200 {
                        if let index = self.videosDataList.firstIndex(of: vidData) {
                            self.videosDataList.remove(at: index)
                        }
                    }
                        
                    else if response.statusCode == 409 { //USERNAME CONFLICT
                        let generator = UINotificationFeedbackGenerator()
                        generator.prepare()
                        generator.notificationOccurred(.error)
                    } else if response.statusCode == 500 {
                        print("Server Error")
                        let generator = UINotificationFeedbackGenerator()
                        generator.prepare()
                        generator.notificationOccurred(.error)
                    } else if response.statusCode == 400 {
                        print("Client Error")
                        let generator = UINotificationFeedbackGenerator()
                        generator.prepare()
                        generator.notificationOccurred(.error)
                    }
                }.resume()
            })
        )
        profileImgActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:
            { _ in
                //closes the action sheet.
            })
        )
        
        self.present(profileImgActionSheet, animated: true, completion: nil)
    }
    
    @objc func handleShareTap(tapGesture: UITapGestureRecognizer){
        guard let vidCell = tapGesture.view?.superview as? VideoCell,
            let avurlAsset = vidCell.player.currentItem?.asset as? AVURLAsset
            else { return }
        let shareURL = avurlAsset.url
        let vc = UIActivityViewController(activityItems: [shareURL], applicationActivities: [])
        self.present(vc, animated: true)
    }
    
    @objc func handleCommentsTap(tapGesture: UITapGestureRecognizer) {
        if !appDelegate.triggerSignInIfNoAccount(customMessgae: "Sign In To Write Comments") { return }
        guard let vidCell = tapGesture.view?.superview as? VideoCell, let vidData = vidCell.currentVideoData else { return }
        
        let vidID =  vidData["video_id"] as? String
        self.commentsViewController.setupComments(forVideo: vidID)
        self.present(self.commentsViewController, animated: true) {
            /*CompletionHandler*/
        }
    }
    
    @objc func handleRefreshControl() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        if let refreshFunc = self.refreshFunction { // We are not the rootVC so we ask for new data
            refreshFunc({ returnedDataList in
                DispatchQueue.main.async {
                    if let newDataList = returnedDataList {
                        self.videosDataList = newDataList
                    }
                    self.collectionView.refreshControl?.endRefreshing()
                }
            })
            
        } else { //We are the rootVC
            fetchVideoList()
        }
        generator.impactOccurred()
    }
    
    @objc func handleGoToProfileTap(tapGesture: UITapGestureRecognizer) {
        
        if let tappedVidCell = tapGesture.view?.superview as? VideoCell {
            
            let tappedProfileVC = MyProfileVC()
            tappedProfileVC.currentProfileData = tappedVidCell.currentVideoData
            self.navigationController?.pushViewController(tappedProfileVC, animated: true)
            self.commentsViewController.dismiss(animated: true, completion: nil)
            
        } else if let tappedCommentCell = tapGesture.view?.superview as? CommentsTableViewCell {
            let tappedProfileVC = MyProfileVC()
            tappedProfileVC.currentProfileData = tappedCommentCell.currentCommentData
            self.navigationController?.pushViewController(tappedProfileVC, animated: true)
            self.commentsViewController.dismiss(animated: true, completion: nil)
            
        }
    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // OBSERVERS /////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    func addReturnToForegroundObserver(){
        returnToForegroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            if let curCell = self.currentCell {
               curCell.isPaused = false
            }
        }
    }
    func removeReturnToForegroundObserver(){
        if let returnToForegroundObserver = returnToForegroundObserver {
            NotificationCenter.default.removeObserver(returnToForegroundObserver)
        }
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // NETWORKING CALLS //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    func fetchVideoList() {
        let videoListURL = URL(string: FlykConfig.mainEndpoint+"/home/")!
        
        var request = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if error != nil {
                print(error)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("not httpurlresponse...!")
                return
            }
            
            if(response.statusCode == 200) {
                do {
                    if let videosList : [NSDictionary] = try JSONSerialization.jsonObject(with: data!, options: []) as? [NSDictionary] {
                        
                        self.videosDataList = videosList.map{ dict -> NSMutableDictionary in dict.mutableCopy() as! NSMutableDictionary}
                    }else{
                        print("VIDEO LIST AS MUTABLE FAILED...")
                    }
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
            } else {
                print("Response not 200", response)
            }
            
        }.resume()
    }


}


