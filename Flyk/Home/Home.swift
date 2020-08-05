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


class Home: UIViewController, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    

    
    var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var videoURLs : [URL] = [] { didSet { DispatchQueue.main.async { self.collectionView.reloadData() } } }
    var currentCell : VideoCell? {
        didSet{
            if let curCell = currentCell {
                if let cellIndex = collectionView.indexPath(for: curCell){
                    if videoURLs.count > 0 && cellIndex.row > (videoURLs.count - 2) {
                        print("FETCH NEW ITEMS HERE")
                    }
                }
            }
        }
    }
    
    var returnToForegroundObserver: NSObjectProtocol?
    
    lazy var commentsViewController: CommentsViewController = {
        let cVc = CommentsViewController()
        cVc.transitioningDelegate = cVc
        cVc.modalPresentationStyle = .custom
        return cVc
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addReturnToForegroundObserver()
        if let currentCell = self.currentCell {
            if !currentCell.isPaused {
                currentCell.player.play()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fetchVideoList() // THIS IS DISABLED FOR TESTING
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: "videoCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
//        collectionView.backgroundColor = UIColor.flykDarkGrey
        self.view.addSubview(collectionView)
        
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        collectionView.decelerationRate = .fast
        
        
        
        collectionView.refreshControl = UIRefreshControl()
        
        collectionView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        collectionView.refreshControl!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        collectionView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        

        print(UIDevice.current.name, UIDevice.current.identifierForVendor?.uuidString)

                
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.isFirstLaunch()
        
//        appDelegate.triggerSignInIfNoAccount(customMessgae: "hi")
    }
    @objc func handleAPNGTap(tapGesture: UITapGestureRecognizer){
        if (tapGesture.view as! UIImageView).isAnimating {
            (tapGesture.view as! UIImageView).stopAnimating()
            (tapGesture.view as! UIImageView).animationImages = nil
        }else{
//            (tapGesture.view as! UIImageView).startAnimating()
        }
    }
    @objc func handleRefreshControl() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        // Update your content…
//        videoURLs = []
        fetchVideoList()
        // Dismiss the refresh control.
//        DispatchQueue.main.async {
//            self.collectionView.refreshControl!.endRefreshing()
//        }
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
        for indexPath in indexPaths {
            let prefetchURL = videoURLs[indexPath.row]
//            asyncFetcher.fetchAsync(model.identifier)
            print(indexPath)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoURLs.count
    }
    
    //
    // THIS CREATES/REUSES CELL
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCell
        cell.share.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShareTap(tapGesture:))))
        
        cell.comments.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCommentsTap(tapGesture:))))
        
        let remoteAsset = AVAsset(url: videoURLs[indexPath.row])
        

        let newPlayer = AVPlayerItem(asset: remoteAsset)
        cell.player.replaceCurrentItem(with: newPlayer)
//        cell.player.playImmediately(atRate: 1.0)
        
        cell.addDidEndObserver()
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height-self.view.safeAreaInsets.bottom)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        let videoCell = cell as! VideoCell
        if self.currentCell == nil {
            self.currentCell = videoCell
            self.currentCell?.isPaused = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
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
    

    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // NETWORKING CALLS //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchVideoList(){
        let videoListURL = URL(string: FlykConfig.mainEndpoint+"/list/")!

        let urlReq = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
        URLSession.shared.dataTask(with: urlReq) { data, response, error in
            DispatchQueue.main.async { self.collectionView.refreshControl!.endRefreshing() }
    
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
                let videoNameList : NSArray = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray
                //                let imgNameList = ["1.jpg", "2.png", "3.png"]
                
                let optionalVidURLs = videoNameList.map({ (vidName) -> URL? in
                    if let vidNameString: String = vidName as? String {
                        if let vidStrURL = URL(string: FlykConfig.mainEndpoint+"/video/" + vidNameString){
                            return vidStrURL
                        }
                    }
                    return nil
                })
                self.videoURLs = optionalVidURLs.filter({ (maybeNill) -> Bool in return maybeNill != nil}) as! [URL]
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }

        }.resume()
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
    
        
    @objc func handleShareTap(tapGesture: UITapGestureRecognizer){
        let shareURL = ((tapGesture.view?.superview as! VideoCell).player.currentItem?.asset as! AVURLAsset).url
        let vc = UIActivityViewController(activityItems: [shareURL], applicationActivities: [])
        self.present(vc, animated: true)
    }
    
    @objc func handleCommentsTap(tapGesture: UITapGestureRecognizer){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.triggerSignInIfNoAccount(customMessgae: "Sign In To Write Comments") {
            self.present(self.commentsViewController, animated: true) {/*CompletionHandler*/}
        }
    }


}


