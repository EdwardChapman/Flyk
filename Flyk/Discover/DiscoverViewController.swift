//
//  SecondViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    
    
    var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var videoURLs : [URL] = [] { didSet { DispatchQueue.main.async { self.collectionView.reloadData() } } }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchVideoList()
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "discoverCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.addSubview(collectionView)
        
        
//        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
//        collectionView.decelerationRate = .fast
        self.view.backgroundColor = UIColor.flykDarkGrey
        collectionView.backgroundColor = UIColor.flykDarkGrey
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }
    
    deinit {

    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // COLLECTIONVIEW DELEGATE ///////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return videoURLs.count
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discoverCell", for: indexPath)

//        cell.player.replaceCurrentItem(with: AVPlayerItem(url: videoURLs[indexPath.row]))
//        let colours = [
//            UIColor.blue,
//            UIColor.red,
//            UIColor.green,
//            UIColor.lightGray,
//            UIColor.black,
//            UIColor.yellow,
//            UIColor.darkGray,
//            UIColor.white
//        ]
//        let rand = arc4random_uniform(UInt32(colours.count))
//        cell.backgroundColor = colours[Int(rand)]
        cell.backgroundColor = UIColor.flykLightDarkGrey
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.view.frame.width, height: self.view.frame.height-self.view.safeAreaInsets.bottom)
        return CGSize(width: self.view.frame.width/3, height: (self.view.frame.width/3)*(16/9))
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
        
        if videoURLs.count > 0 && indexPath.row > (videoURLs.count - 2) {
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
        
        URLSession.shared.dataTask(with: URL(string: "https://swiftytest.uc.r.appspot.com/list/videos")!) { data, response, error in
            
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
                        if let vidStrURL = URL(string:"https://swiftytest.uc.r.appspot.com/videos/" + vidNameString){
                            return vidStrURL
                        }
                    }
                    return nil
                })
                
                self.videoURLs.append(contentsOf:optionalVidURLs.filter({ (maybeNill) -> Bool in return maybeNill != nil}) as! [URL])
                //                DispatchQueue.main.async {
                //                    self.collectionView.reloadData()
                //                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
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

