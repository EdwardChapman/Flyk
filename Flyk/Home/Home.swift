//
//  FirstViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation


class Home: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        self.collectionView = UICollectionView(
            frame: CGRect(
                x: self.view.frame.minX,
                y: self.view.frame.minY,
                width: self.view.frame.width,
                height: self.view.frame.height - (self.tabBarController?.tabBar.frame.height)!),
            collectionViewLayout: flowLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.cyan
        self.view.addSubview(collectionView)
        
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        collectionView.decelerationRate = .fast
        self.view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        collectionView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath as IndexPath)
        
        cell.backgroundColor = UIColor.green
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.height-self.view.safeAreaInsets.bottom)
    }
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return self.view.frame.size
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("DIDENDDRAGGING")
        var closestCell : UICollectionViewCell?
        for cell in collectionView.visibleCells {
            let indexPath = collectionView.indexPath(for: cell)
            
            let curScroll = scrollView.contentOffset.y
            if closestCell == nil {
                closestCell = cell
            }else{
                if abs(cell.frame.minY - curScroll) < abs(closestCell!.frame.minY - curScroll) {
                    closestCell = cell
                }
            }
        }
        
//        UIView.animate(withDuration: 0.3, animations: {
//        scrollView.setContentOffset(CGPoint(x: 0, y:(closestCell?.frame.minY)!), animated: true)
        
//            scrollView.contentOffset.y = (closestCell?.contentView.frame.minY)!
//        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }

}

