//
//  PostsCarouselCollectionViewController.swift
//  Flyk
//
//  Created by Edward Chapman on 8/9/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation

private let reuseIdentifier = "CarouselCell"

class PostsCarouselCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    weak var parentCollectionView: PostsCollectionView?
    var returnToForegroundObserver: NSObjectProtocol?
    
    
    var currentCell : VideoCell? {
        didSet{
            if let curCell = currentCell {
                if let cellIndex = collectionView.indexPath(for: curCell){
                    if let videosDataList = parentCollectionView?.videoDataList {
                        if videosDataList.count > 0 && cellIndex.row > (videosDataList.count - 2) {
                            print("FETCH NEW ITEMS HERE")
                        }
                    }
                }
            }
        }
    }
    
    var startingIndexPath: IndexPath?
    
    init(collectionViewLayout layout: UICollectionViewLayout, parentCollectionView: PostsCollectionView, startingIndexPath: IndexPath) {
        super.init(collectionViewLayout: layout)
        self.parentCollectionView = parentCollectionView
        self.startingIndexPath = startingIndexPath
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    var shouldScrollToIndexPath: IndexPath?
//
//    override func viewWillAppear(_ animated: Bool) {
//        if let indexPath = self.shouldScrollToIndexPath {
//            self.view.layoutIfNeeded()
//            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
//            shouldScrollToIndexPath = nil
//        }
//    }

    var previousInteractivePopGestureDelegate: UIGestureRecognizerDelegate?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        super.viewWillDisappear(animated)
        if let prevDel = previousInteractivePopGestureDelegate {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = prevDel
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(VideoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: "videoCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        /*
        collectionView.prefetchDataSource = self
        */
        
        self.view.addSubview(collectionView)
        
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        collectionView.decelerationRate = .fast
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        
        
        collectionView.refreshControl = UIRefreshControl()
        
//        collectionView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        collectionView.refreshControl!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        collectionView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let superVC = self.parentCollectionView {
            return superVC.videoDataList.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VideoCell
        
        if let superVC = self.parentCollectionView {
            let videosDataList = superVC.videoDataList
//            cell.share.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShareTap(tapGesture:))))
            
//            cell.comments.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCommentsTap(tapGesture:))))
            
//            print(videosDataList[indexPath.row])
            
            let targetEndpointString = FlykConfig.mainEndpoint+"/video/"
            let videoFilename =  videosDataList[indexPath.row]["video_filename"] as! String
            let remoteAssetUrl = URL(string: targetEndpointString + videoFilename)!
            let remoteAsset = AVAsset(url: remoteAssetUrl)
            
            
            cell.setupNewVideo(fromDict: videosDataList[indexPath.row])
            cell.addDidEndObserver()
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height-self.view.safeAreaInsets.bottom)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        let videoCell = cell as! VideoCell
        if self.currentCell == nil && (self.startingIndexPath == nil || self.startingIndexPath! == indexPath){
            self.currentCell = videoCell
            self.currentCell?.isPaused = false
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // SCROLLVIEW DELEGATE ///////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
    /*
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    */
    
    
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
    
    
    @objc func handleShareTap(tapGesture: UITapGestureRecognizer){
        let shareURL = ((tapGesture.view?.superview as! VideoCell).player.currentItem?.asset as! AVURLAsset).url
        let vc = UIActivityViewController(activityItems: [shareURL], applicationActivities: [])
        self.present(vc, animated: true)
    }
    /*
    @objc func handleCommentsTap(tapGesture: UITapGestureRecognizer){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.triggerSignInIfNoAccount(customMessgae: "Sign In To Write Comments") {
            self.present(self.commentsViewController, animated: true) {/*CompletionHandler*/}
        }
    }
    */

}
