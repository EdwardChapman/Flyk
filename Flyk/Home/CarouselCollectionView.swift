//
//  CarouselCollectionView.swift
//  Flyk
//
//  Created by Edward Chapman on 8/17/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//
/*
import UIKit

class CarouselCollectionView: UICollectionView {
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        self.register(VideoCell.self, forCellWithReuseIdentifier: "videoCell")
        self.delegate = self
        self.dataSource = self
        self.prefetchDataSource = self
        //        collectionView.backgroundColor = UIColor.flykDarkGrey
        self.view.addSubview(self)
        
        
        self.contentInsetAdjustmentBehavior = .never
        self.isPagingEnabled = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        self.decelerationRate = .fast
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        self.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
        self.refreshControl!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        self.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.refreshControl?.beginRefreshing()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

*/
