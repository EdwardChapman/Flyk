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
    var videosDataList : [NSDictionary] = [] { didSet { DispatchQueue.main.async { self.collectionView.reloadData() } } }
    
    var currentCell : VideoCell? {
        didSet{
            if let curCell = currentCell {
                if let cellIndex = collectionView.indexPath(for: curCell){
                    if videosDataList.count > 0 && cellIndex.row > (videosDataList.count - 2) {
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
        
        
//        fetchVideoList() // THIS IS DISABLED FOR TESTING
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
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        
        
        collectionView.refreshControl = UIRefreshControl()
        
        collectionView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        collectionView.refreshControl!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        collectionView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        collectionView.refreshControl?.beginRefreshing()
        fetchVideoList()

        print(UIDevice.current.name, UIDevice.current.identifierForVendor?.uuidString)

        //Cookie name is flyk
        //All I need is the cookie value
        
//        var mainCookie = URLSession.shared.configuration.httpCookieStorage?.cookies(for: URL(string:FlykConfig.mainEndpoint)!)![0]
//        mainCookie?.domain = FlykConfig.uploadEndpoint
//        mainCookie.
//        
//        URLSession.shared.configuration.httpCookieStorage?.setCookies( [mainCookie],
//            for: URL(string: FlykConfig.uploadEndpoint), mainDocumentURL: nil
//        )
//        print(URLSession.shared.configuration.httpCookieStorage?.cookies(for: URL(string:FlykConfig.uploadEndpoint)!))
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.isFirstLaunch()
        
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
            let prefetchURL = videosDataList[indexPath.row]["videoFilename"]
//            asyncFetcher.fetchAsync(model.identifier)
            print(indexPath)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videosDataList.count
    }
    
    //
    // THIS CREATES/REUSES CELL
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCell
        cell.share.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShareTap(tapGesture:))))
        
        cell.comments.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCommentsTap(tapGesture:))))
        
        print(videosDataList[indexPath.row])
        
        let targetEndpointString = FlykConfig.mainEndpoint+"/video/"
        let videoFilename =  videosDataList[indexPath.row]["video_filename"] as! String
        let remoteAssetUrl = URL(string: targetEndpointString + videoFilename)!
        let remoteAsset = AVAsset(url: remoteAssetUrl)
        
        
        cell.setupNewVideo(fromDict: videosDataList[indexPath.row])
        /*

        let newPlayer = AVPlayerItem(asset: remoteAsset)
        cell.player.replaceCurrentItem(with: newPlayer)
        
        cell.usernameLabel.text = videosDataList[indexPath.row]["username"] as? String
        print(cell.usernameLabel.attributedText!.size())
        cell.usernameLabel.frame.size = cell.usernameLabel.attributedText!.size()
        
        
        cell.descriptionTextView.text = videosDataList[indexPath.row]["video_description"] as? String
        print(cell.descriptionTextView.attributedText!.size())
        cell.descriptionTextView.frame.size = cell.descriptionTextView.attributedText!.size()
        
        if let profile_img_filename = videosDataList[indexPath.row]["profile_img_filename"] as? String {
            print("PROFIELE IMG FILENAME ESITS")
        }else{
            print("PROFILE IMG FILENAME DNE")
        }
        */
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
        let videoListURL = URL(string: FlykConfig.mainEndpoint+"/home/")!

        var request = URLRequest(url: videoListURL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.collectionView.refreshControl!.endRefreshing() }
            
            if error != nil {
                print(error)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("not httpurlresponse...!")
                return;
            }
            
            if(response.statusCode == 200) {
                do {
                    if let videosList : [NSDictionary] = try JSONSerialization.jsonObject(with: data!, options: []) as? [NSDictionary] {
                        self.videosDataList = videosList
                    }
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
            }else{
                print("Response not 200", response)
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


