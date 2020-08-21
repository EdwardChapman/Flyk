//
//  SecondViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation

class DiscoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var videoDataList : [NSMutableDictionary] = [] { didSet { DispatchQueue.main.async { self.collectionView.reloadData() } } }
    
    let searchBar = UISearchBar()
    
    lazy var searchTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .flykDarkGrey
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(NoticationCell.self, forCellReuseIdentifier: "searchCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    var searchResultsList: [NSMutableDictionary] = [NSMutableDictionary(objects: ["First Result"], forKeys: ["message" as NSCopying])]
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResultsList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = (self.searchTableView.dequeueReusableCell(withIdentifier: "searchCell") as! NoticationCell?)!
        
        // set the text from the data model
        //        cell.backgroundColor = .flykDarkGrey
        cell.notificationLabel.text = self.searchResultsList[indexPath.row]["message"] as! String
        //        cell.textLabel?.textColor = .white
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    
    
    
    var searchTableViewBottomAnchorTall: NSLayoutConstraint?
    
    
    
    /*
    var keyboardHeight: CGFloat? {
        didSet {
            if let keyboardHeight = self.keyboardHeight {
                searchTableViewBottomAnchorTall!.constant = -(keyboardHeight)
            }else{
                searchTableViewBottomAnchorTall!.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func keyboardWillShow(notification:NSNotification) {
        if let keyboardRectValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardRectValue.height
            print("KEYBOARD WILL Show")
        }
    }
    
    @objc fileprivate func keyboardWillHide(notification: NSNotification) {
        print("KEYBOARD WILL HIDE")
        self.keyboardHeight = nil
    }
    
    func addKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeKeyboardObserver(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
 
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchVideoList() // THIS IS DISABLED FOR TESTING
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        collectionView.register(PostsCell.self, forCellWithReuseIdentifier: "discoverCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.addSubview(collectionView)
        
        
        self.view.addSubview(searchBar)
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .flykDarkWhite
        searchBar.barStyle = .black
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        
        
        self.view.layoutIfNeeded()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: searchBar.intrinsicContentSize.height).isActive = true
        
//        collectionView.contentInsetAdjustmentBehavior = .never
//        let searchResultsVC = UIViewController()
//        searchResultsVC.view.backgroundColor = .blue
//        let searchController = DiscoverSearchController(searchResultsController: searchResultsVC)
//
//        searchController.styleSearchBar()
////        let searchBar = searchController.searchBar
//        self.view.addSubview(searchController.searchBar)
//
//        self.view.layoutIfNeeded()
//        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
//        searchController.searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        searchController.searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//        searchController.searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
//        searchController.searchBar.heightAnchor.constraint(equalToConstant: searchController.searchBar.intrinsicContentSize.height).isActive = true
//
////        searchController.isActive = true
////        searchBar.delegate = self
////        searchController.delegate = self // THIS IS FUCKED....
//        searchController.obscuresBackgroundDuringPresentation = false
//
//        searchController.delegate = self
//        searchController.searchResultsUpdater = searchController
//        searchController.searchBar.autocapitalizationType = .none
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.searchBar.delegate = self // Monitor when the search button is tapped.
        
        
        
        
        
        
        
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
//        collectionView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.refreshControl!.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 10).isActive = true
//        collectionView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        
        
        self.view.addSubview(searchTableView)
        
        searchTableView.translatesAutoresizingMaskIntoConstraints = false
        searchTableView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
        searchTableView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true
        searchTableView.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        self.searchTableViewBottomAnchorTall = searchTableView.bottomAnchor.constraint(equalTo: self.collectionView.bottomAnchor)
        self.searchTableViewBottomAnchorTall!.isActive = true
        
        searchTableView.isHidden = true
        
//        loadingPlaceholderSetup()
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //SearchBarDelegate ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        // THIS IS WHERE WE QUERY WITH THE SEARCH TEXT
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        print(trimmedSearch)
        // DO THE SEARCH FETCH HERE.....
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchTableView.isHidden = false
        searchBar.setShowsCancelButton(true, animated: true)
        print("searchbar did begin editing")
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.endEditing(true)
        print("searchbar cancel button clicked.")
        searchTableView.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        print("Search bar button clicked.")
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
        generator.prepare()
        fetchVideoList() // This dismisses the refresh control
        generator.impactOccurred()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discoverCell", for: indexPath) as! PostsCell
        
        /* APNG/GIF SETUP */
        let targetPath = FlykConfig.mainEndpoint+"/video/animatedThumbnail/"
        if let apngFilename = videoDataList[indexPath.row]["apng_filename"] as? String {
            let apngUrl = URL(string: targetPath + apngFilename)
            
            if let apngTestImgView = UIImageView.fromGif(frame: cell.frame, assetUrl: apngUrl, autoReverse: true) {
                apngTestImgView.frame = cell.bounds
                
                cell.swapUIImageGifView(newGifView: apngTestImgView)
                
            }
        }
        
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.view.frame.width, height: self.view.frame.height-self.view.safeAreaInsets.bottom)
        return CGSize(width: (self.view.frame.width/3), height: (self.view.frame.width/3)*(16/9))
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
//        print("DID END DISPLAYING CELL")
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // push view controller with swipe collectionview
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        let newVC = PostsCarouselCollectionVC(collectionViewLayout: flowLayout, videoDataList: self.videoDataList, startingIndexPath: indexPath)
        
        
        
        newVC.view.layoutIfNeeded()
        newVC.collectionView.setContentOffset(CGPoint(x: .zero, y: (self.view.frame.height - (self.tabBarController?.tabBar.frame.height)!) * CGFloat(indexPath.row)), animated: false)
//        newVC.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        
        
        
        
        self.navigationController?.pushViewController(newVC, animated: true)
        return false
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
        if !scrollView.isDecelerating && scrollView == self.searchTableView {
            self.view.endEditing(true)
        }
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
                        self.videoDataList = videosList.map{ dict -> NSMutableDictionary in dict.mutableCopy() as! NSMutableDictionary}
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

