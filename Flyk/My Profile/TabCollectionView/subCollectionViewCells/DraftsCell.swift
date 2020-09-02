//
//  DraftsCell.swift
//  Flyk
//
//  Created by Edward Chapman on 7/26/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData



class DraftsCell: UICollectionViewCell {
    
    var currentDraftObject: NSManagedObject?
    
    let gifImgView = UIImageView()
    
    lazy var cellOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.flykBlue
        v.alpha = 0.6
        self.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        let zeroHeight = v.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0)
        let fullHeight = v.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1)
        zeroHeight.isActive = true
        v.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.layoutIfNeeded()
        
        UIView.animate(withDuration: 10, animations: {
            zeroHeight.isActive = false
            fullHeight.isActive = true
            self.layoutIfNeeded()
        }, completion: { (finished) in
            self.uploadingLabel.text = "Processing"
            self.barberProgressBar.isHidden = false
            self.barberProgressBar.isAnimating = true
        })
        
        return v
    }()
    
    lazy var uploadingLabel: UILabel = {
        let l = UILabel()
        self.addSubview(l)
        l.text = "Processing"
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        l.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        l.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20).isActive = true
        return l
    }()
    
    lazy var barberProgressBar: BarberProgressBar = {
        let progressInd = BarberProgressBar(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        self.addSubview(progressInd)
        progressInd.isAnimating = true
        progressInd.translatesAutoresizingMaskIntoConstraints = false
        progressInd.topAnchor.constraint(equalTo: self.uploadingLabel.bottomAnchor, constant: 10).isActive = true
        progressInd.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        progressInd.heightAnchor.constraint(equalToConstant: 20).isActive = true
        progressInd.widthAnchor.constraint(equalToConstant: 80).isActive = true
        progressInd.layer.cornerRadius = 10
        progressInd.clipsToBounds = true
        progressInd.isHidden = true
        return progressInd
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(gifImgView)
        gifImgView.translatesAutoresizingMaskIntoConstraints = false
        gifImgView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        gifImgView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        gifImgView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        gifImgView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        gifImgView.contentMode = .scaleToFill
        self.backgroundColor = .flykMediumGrey
        
        self.cellOverlay.isHidden = false
        self.uploadingLabel.text = "Uploading"
        
        
    }

    
    func setupNewDraft(newDraft : NSManagedObject) {
        self.currentDraftObject = newDraft
        self.addContextObserver()
        
        DispatchQueue.global(qos: .background).async {
            
            if let savedURL = newDraft.value(forKey: "filename") as? String {
                let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    .appendingPathComponent(savedURL)
                let videoAsset = AVAsset(url: documentsUrl)
                
                let imgGenerator = AVAssetImageGenerator(asset: videoAsset)
                imgGenerator.requestedTimeToleranceBefore = .zero
                imgGenerator.requestedTimeToleranceAfter = .zero
                
                let startTime = 0
                let sampleLength = 0.5
                let framesPerSecond: Double = 10
                let numSamples = Int(sampleLength * framesPerSecond)
                
                var images = [UIImage]()
                
                
                for i in 0...(numSamples-1){
                    let iTime = CMTime(seconds: (Double(i)/framesPerSecond) + Double(startTime), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                    do {
                        var a = CMTime()
                        let imageRef = try imgGenerator.copyCGImage(at: iTime, actualTime: &a)
                        print("req", iTime)
                        print("actual", a)
                        images.append(UIImage(cgImage: imageRef))
                    } catch {
                        print(error)
                    }
                }
                let autoReverse = true
                let origLength = images.count - 1
                if autoReverse {
                    for i in 0..<images.count {
                        images.append(images[origLength-i])
                    }
                }
                
                DispatchQueue.main.async {
                    self.gifImgView.animationDuration = 1
                    self.gifImgView.animationImages = images
                    self.gifImgView.isUserInteractionEnabled = false
                    self.gifImgView.startAnimating()
                    
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gifImgView.stopAnimating()
        gifImgView.animationImages = nil
        self.currentDraftObject = nil
        self.removeContextObserver()
    }
    
    
    override var isHighlighted: Bool {
        set { /* Do nothing b/c we don't want to highlight. */ }
        get { return super.isHighlighted }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    lazy var context = appDelegate.persistentContainer.viewContext
    
    var contextObserverObj: NSObjectProtocol?
    func addContextObserver() {
        
        self.contextObserverObj = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context, queue: .main){ [unowned self] notification in
            
            guard let userInfo = notification.userInfo,
                let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
                let curDraftObj = self.currentDraftObject
                else { return }
        
            if updates.contains(curDraftObj) {
                guard let uploadStatus = curDraftObj.value(forKey: "uploadStatus") as? String
                    else { return }
                if uploadStatus == "uploading" {
//                    draft.setValue(0, forKey: "uploadProgress")
                    
             
                }
            }
        }
    }
    
    func removeContextObserver() {
        if let obs = self.contextObserverObj {
            NotificationCenter.default.removeObserver(obs)
            self.contextObserverObj = nil
        }
    }
    
}



 
 
 
 
 
 
 
 
 

 



class BarberProgressBar: UIView {
    
    var wasAnimating: Bool = false
    var isAnimating: Bool = false {
        willSet {
            wasAnimating = self.isAnimating
        }
        didSet {
            if self.wasAnimating != self.isAnimating {
                if self.isAnimating {
                    // start animation
                    processingBar.backgroundColor = .white
                    UIView.animate(withDuration: 0.7, delay: 0, options: [.curveLinear, .repeat], animations: {
                        self.processingBar.frame.origin = CGPoint(x: 0, y: 0)
                    }, completion: { (finished) in
                        if !finished {
                            self.isAnimating = false
                        }
                    })
                } else {
                    
                }
            }
        }
    }
    
    let numberOfSlants: CGFloat = 5
    lazy var processingBar: UIView = {
        
        let p = UIView()
        
        p.frame = CGRect(
            x: -self.frame.width/self.numberOfSlants,
            y: 0,
            width: self.bounds.width + self.frame.width/self.numberOfSlants,
            height: self.bounds.height
        )
        
        p.backgroundColor = .white
        
        var lastSlant: UIView? = nil
        for slantNum in 0...Int(self.numberOfSlants) {
            let slant = UIView()
            slant.backgroundColor = UIColor.flykBlue
            p.addSubview(slant)
            slant.frame = CGRect(
                x: CGFloat(slantNum) * (self.frame.width / self.numberOfSlants),
                y: -0.25 * p.frame.height,
                width: self.frame.width / (self.numberOfSlants * 2),
                height: p.frame.height * 1.5
            )
            slant.transform = slant.transform.rotated(by: 3.14*(1/6))
        }
        
        //        p.transform = p.transform.rotated(by: 3.14*(1/6))
        
        return p
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.processingBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


