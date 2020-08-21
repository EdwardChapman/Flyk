//
//  PostsCell.swift
//  Flyk
//
//  Created by Edward Chapman on 7/26/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation


class PostsCell: UICollectionViewCell {
    
    var gifImageView: UIImageView?
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = .flykMediumGrey
        
    }
    
    func swapUIImageGifView(newGifView: UIImageView) {
        self.gifImageView = newGifView
        self.addSubview(newGifView)
    }
    


    override func prepareForReuse() {
        super.prepareForReuse()
        if let gifImageView = self.gifImageView {
            self.gifImageView!.stopAnimating()
            self.gifImageView!.animationImages = nil
            self.gifImageView!.removeFromSuperview()
            self.gifImageView = nil
        }
        
    }
    
    override var isHighlighted: Bool {
        set {
            //Do nothing b/c we don't want to highlight.
        }
        get {
            return super.isHighlighted
        }
    }
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



