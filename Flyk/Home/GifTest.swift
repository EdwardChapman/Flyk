//
//  GifTest.swift
//  Flyk
//
//  Created by Edward Chapman on 7/28/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit


extension UIImageView {
    static func fromGif(frame: CGRect, assetUrl: URL?, autoReverse: Bool) -> UIImageView? {
        

//        guard let path = Bundle.main.path(forResource: resourceName, ofType: "") else {
//            print("Gif does not exist at that path")
//            return nil
//        }
//        let url = URL(fileURLWithPath: path)
        if let assetUrl = assetUrl {
            guard let gifData = try? Data(contentsOf: assetUrl),
                let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
            var images = [UIImage]()
            let imageCount = CGImageSourceGetCount(source)
            for i in 0 ..< imageCount {
                if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: image))
                }
            }
            let origLength = images.count - 1
            if autoReverse { for i in 0..<images.count { images.append(images[origLength-i]) } }
            
            let gifImageView = UIImageView(frame: frame)
            gifImageView.animationImages = images
            return gifImageView
        }else{
            return nil
        }
        
    }
    
    /* APNG/GIF SETUP
     //        let apngUrl = URL(string: "https://75d87dnb.tinifycdn.com/blog/2016/09/animated-png-compression/images/040_SM_24FPS_RGBA-compressed-02b1d659.png")
     //        let apngUrl = URL(string: "https://static.ezgif.com/images/format-demo/butterfly.png")
     let apngUrl = URL(string:"https://storage.googleapis.com/swifty_animated_thumbnails/1a5fbf1b-3a70-4ad5-8bec-0357cfd1ad8c")
     if let apngTestImgView = UIImageView.fromGif(frame: view.frame, assetUrl: apngUrl, autoReverse: true) {
     //        view.addSubview(confettiImageView)
     apngTestImgView.animationDuration = 1
     apngTestImgView.startAnimating()
     //        let apngImg = UIImage(named:"apngTest")
     //        let apngTestImgView = UIImageView(image: apngImg)
     self.view.addSubview(apngTestImgView)
     apngTestImgView.contentMode = .scaleAspectFit
     let cellWidth = self.view.frame.width/CGFloat(3)
     apngTestImgView.frame = CGRect(x: 80, y: 400, width: cellWidth, height: cellWidth*(16/9))
     apngTestImgView.isUserInteractionEnabled = true
     apngTestImgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAPNGTap(tapGesture:))))
     
     for key in apngTestImgView.layer.animationKeys()! {
     print(apngTestImgView.layer.animation(forKey: key)!)
     }
     
     }
     */
}
