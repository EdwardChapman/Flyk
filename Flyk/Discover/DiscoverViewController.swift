//
//  SecondViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation

class DiscoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    
    
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var videoDataList : [NSDictionary] = [] { didSet { DispatchQueue.main.async { self.collectionView.reloadData() } } }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchVideoList() // THIS IS DISABLED FOR TESTING
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.5
        flowLayout.minimumInteritemSpacing = 0.5
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "discoverCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.addSubview(collectionView)
        
        
//        collectionView.contentInsetAdjustmentBehavior = .never
        let searchBar = DiscoverSearchBar()
        self.view.addSubview(searchBar)
        searchBar.setupConstraints()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
//        collectionView.decelerationRate = .fast
        self.view.backgroundColor = UIColor.flykDarkGrey
        collectionView.backgroundColor = UIColor.flykDarkGrey
        
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        collectionView.refreshControl!.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 10).isActive = true
        collectionView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
//        loadingPlaceholderSetup()
    }
    
    func loadingPlaceholderSetup(){
        let placeholderView = UIView()
        self.view.addSubview(placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.leadingAnchor.constraint(equalTo: self.collectionView.leadingAnchor).isActive = true
        placeholderView.trailingAnchor.constraint(equalTo: self.collectionView.trailingAnchor).isActive = true
        placeholderView.topAnchor.constraint(equalTo: self.collectionView.topAnchor).isActive = true
        placeholderView.bottomAnchor.constraint(equalTo: self.collectionView.bottomAnchor).isActive = true
        self.view.layoutIfNeeded()
        let cellSize = CGSize(width: (self.view.frame.width/3)-0.33, height: (self.view.frame.width/3)*(16/9))
        var itemOriginY: CGFloat = 0
        while itemOriginY < self.view.frame.height - (self.tabBarController?.tabBar.frame.height)! {
            for i in 0...2 {
                let p = UIView(frame: CGRect(origin: CGPoint(x: (CGFloat(i)*cellSize.width)+(0.33*CGFloat(i)), y: itemOriginY), size: cellSize))
                placeholderView.addSubview(p)
                p.backgroundColor = .flykMediumGrey
                p.alpha = 0.9
            }
            itemOriginY += cellSize.height + 0.5
        }
        let loadingBar = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 4, height: placeholderView.bounds.height)))
        loadingBar.backgroundColor = .flykBlue
        loadingBar.alpha = 0.4
        placeholderView.addSubview(loadingBar)
        UIView.animate(withDuration: 1.4, delay: 0, options: [.repeat, .curveEaseInOut], animations: {
            loadingBar.frame.origin = CGPoint(x: (loadingBar.superview?.bounds.width)!, y: 0)
        }) { (finished) in

        }
    }
    @objc func handleRefreshControl() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        fetchVideoList()
        // Dismiss the refresh control.
        DispatchQueue.main.async { self.collectionView.refreshControl!.endRefreshing() }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {

    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // COLLECTIONVIEW DELEGATE ///////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return videoURLs.count
        return videoDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discoverCell", for: indexPath)

        let apngImgView = UIImageView(frame: cell.layer.bounds)
        
        
        /* APNG/GIF SETUP */
        let targetPath = FlykConfig.mainEndpoint+"/video/animatedThumbnail/"
        if let apngFilename = videoDataList[indexPath.row]["apng_filename"] as? String {
            let apngUrl = URL(string: targetPath + apngFilename)
            
            if let apngTestImgView = UIImageView.fromGif(frame: view.frame, assetUrl: apngUrl, autoReverse: true) {
                apngTestImgView.animationDuration = 1
                apngTestImgView.startAnimating()
                apngTestImgView.frame = cell.bounds
                cell.addSubview(apngTestImgView)
                apngTestImgView.contentMode = .scaleAspectFit
            }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.view.frame.width, height: self.view.frame.height-self.view.safeAreaInsets.bottom)
        return CGSize(width: (self.view.frame.width/3)-1, height: (self.view.frame.width/3)*(16/9))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
//        let videoCell = cell as! VideoCell
//        if let currentCell = self.currentCell {
//            currentCell.player.pause()
//            currentCell.player.seek(to: .zero)
//            self.currentCell = videoCell
//        }else{
//            self.currentCell = videoCell
//            self.currentCell?.player.play()
//        }
        
        if videoDataList.count > 0 && indexPath.row > (videoDataList.count - 2) {
            print("FETCH NEW ITEMS HERE")
        }
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
//        self.currentCell!.player.play()
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
        let videoListURL = URL(string: FlykConfig.mainEndpoint+"/discover/")!
        
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
                        self.videoDataList = videosList
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
//        returnToForegroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
//            self.currentCell?.player.play()
//        }
    }
    func removeReturnToForegroundObserver(){
//        if let returnToForegroundObserver = returnToForegroundObserver {
//            NotificationCenter.default.removeObserver(returnToForegroundObserver)
//        }
    }
    
    
    
    
    
    
}

