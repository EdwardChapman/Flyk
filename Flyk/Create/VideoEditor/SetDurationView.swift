//
//  SetDurationView.swift
//  Flyk
//
//  Created by Edward Chapman on 7/12/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import AVFoundation
import UIKit

class SetDurationView : UIView{
    
    let trackViewHeight : CGFloat = 40
    let leftPadding: CGFloat = 25
    let draggerWidth :CGFloat = 15
    
    private var _leftDrag_per :CGFloat = 0
    private var _rightDrag_per :CGFloat = 1
    
    lazy var doneButton: UIImageView = {
        let doneB = UIImageView(frame: .zero)
        self.addSubview(doneB)
        doneB.translatesAutoresizingMaskIntoConstraints = false
        
        doneB.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30).isActive = true
        doneB.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30).isActive = true
        doneB.widthAnchor.constraint(equalToConstant: 30).isActive = true
        doneB.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        doneB.layer.cornerRadius = doneB.frame.height/2
//        doneB.backgroundColor = UIColor.flykBlue
//        doneB.layer.borderWidth = 1
//        doneB.layer.borderColor = UIColor.white.cgColor
        doneB.image = UIImage(named: "blueCheckAlone")
        doneB.isUserInteractionEnabled = true
        doneB.contentMode = UIView.ContentMode.scaleAspectFit
        
        return doneB
    }()
    
    
    lazy var timeCursor: UIView = {
        let cursor = UIView(frame: CGRect(x: CGFloat(currentPlayPercentage) * (thumbnailView.frame.width - 5) + draggerWidth,
                                          y: thumbnailView.frame.minY,
                                          width: 3,
                                          height: thumbnailView.frame.height))

        trackView.addSubview(cursor)
        cursor.layer.cornerRadius = 4
        cursor.backgroundColor = .white
        return cursor
    }()
    var currentPlayPercentage: Double = 0 {
        didSet{
            timeCursor.frame = CGRect(x: CGFloat(currentPlayPercentage) * (thumbnailView.frame.width - 5) + draggerWidth ,
                y: timeCursor.frame.minY,
                width: timeCursor.frame.width,
                height: timeCursor.frame.height)
        }
    }
    
    var leftDragPercentage: CGFloat {
        get{return _leftDrag_per}
        set(newPercent) {
            if newPercent < CGFloat(0) {
                _leftDrag_per = 0
            }else if newPercent > CGFloat(1){
                _leftDrag_per = 1
            }else{
                _leftDrag_per = newPercent
            }
            if rightDragPercentage - leftDragPercentage < 0{
                //move rightDrag first
                _leftDrag_per += rightDragPercentage - leftDragPercentage
            }
            updateLeftSlider()
        }
    }
    var rightDragPercentage: CGFloat{
        get{return _rightDrag_per}
        set(newPercent) {
            if newPercent < CGFloat(0) {
                _rightDrag_per = 0
            }else if newPercent > CGFloat(1){
                _rightDrag_per = 1
            }else{
                _rightDrag_per = newPercent
            }
            if rightDragPercentage - leftDragPercentage < 0 {
                _rightDrag_per -= rightDragPercentage - leftDragPercentage
            }
            updateRightSlider()
        }
    }
    
    func updateLeftSlider(){
        let newX = self.leftDragPercentage * self.thumbnailView.frame.width
        let newFrame = CGRect(
            x: newX,
            y: 0,
            width: (self.thumbnailView.frame.width * self.rightDragPercentage) - newX + self.draggerWidth*2,
            height: (self.leftTabDragger.superview!.frame.height))
        
        self.leftTabDragger.superview!.frame = newFrame
    }
    
    func updateRightSlider(){
        let newX = self.leftDragPercentage * self.thumbnailView.frame.width
        let newFrame = CGRect(
            x: (self.rightTabDragger.superview?.frame.minX)!,
            y: 0,
            width: (self.thumbnailView.frame.width * self.rightDragPercentage) - newX + self.draggerWidth*2,
            height: (self.rightTabDragger.superview?.frame.height)!)
        
        self.rightTabDragger.superview?.frame = newFrame
    }
    
    func replaceLeftPercentWithValidNumber(left: CGFloat?){
        if left == nil {
            _leftDrag_per = 0
        }else{
            _leftDrag_per = left!
        }
    }
    func replaceRightPercentWithValidNumber(right: CGFloat?){
        if right == nil{
            _rightDrag_per = 1
        }else{
            _rightDrag_per = right!
        }
    }
    func replaceBothPercentValuesWithValidNumbers(left: CGFloat?, right: CGFloat?){
        if left == nil {
            _leftDrag_per = 0
        }else{
            _leftDrag_per = left!
        }
        if right == nil{
            _rightDrag_per = 1
        }else{
            _rightDrag_per = right!
        }
        updateLeftSlider()
        updateRightSlider()
    }
    
    
    var thumbnailView: UIView = UIView()
    var trackView: UIView = UIView()
    let windowDragger = UIView()
    let leftTabDragger = UIView()
    let rightTabDragger = UIView()
    
    override var isHidden: Bool {
        get { return super.isHidden }
        set(shouldHide) {
            UIView.animate(withDuration: 0.3, animations: {
                if shouldHide {
                    self.center.y += self.frame.height
                }else{
                    super.isHidden = false
                    self.center.y -= self.frame.height
                }
            }, completion: { finished in
                if shouldHide {super.isHidden = true}
            })
        }
    }

    

    override init(frame: CGRect){
        super.init(frame: frame)
        super.isHidden = true
        self.backgroundColor = UIColor.flykDarkGrey

        trackView.frame = CGRect(x: leftPadding, y: self.bounds.midY - (trackViewHeight/2), width: self.frame.width - (leftPadding*2), height: trackViewHeight)
        self.addSubview(trackView)
        
        
        thumbnailView.frame = CGRect(x: draggerWidth, y: 0, width: trackView.frame.width - draggerWidth*2, height: trackView.frame.height)
        trackView.addSubview(thumbnailView)
        

        trackView.addSubview(windowDragger)
        windowDragger.layer.cornerRadius = 4
        windowDragger.frame = trackView.bounds
        windowDragger.layer.borderWidth = 1
        windowDragger.layer.borderColor = UIColor.flykBlue.cgColor
        
        setupLeftDragger()
        setupRightDragger()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLeftDragger(){
        leftTabDragger.frame = CGRect(x: 0.0, y: 0.0, width: draggerWidth, height: windowDragger.frame.height)
        windowDragger.addSubview(leftTabDragger)
        
        
        leftTabDragger.backgroundColor = UIColor.flykBlue
        leftTabDragger.layer.cornerRadius = 4
        leftTabDragger.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        
        
        
        
        let leftLineOne = UIView(frame: CGRect(x: 2.5, y: leftTabDragger.bounds.height/4, width: 1, height: leftTabDragger.bounds.height/2))
        leftLineOne.backgroundColor = .white
        leftTabDragger.addSubview(leftLineOne)
        
        let leftLineTwo = UIView(frame: CGRect(x: 5, y: (3*leftTabDragger.bounds.height/8), width: 1, height: leftTabDragger.bounds.height/4))
        leftLineTwo.backgroundColor = .white
        leftTabDragger.addSubview(leftLineTwo)
        
        let leftLineThree = UIView(frame: CGRect(x: 7.5, y: leftTabDragger.bounds.height/4, width: 1, height: leftTabDragger.bounds.height/2))
        leftLineThree.backgroundColor = .white
        leftTabDragger.addSubview(leftLineThree)
        
        leftTabDragger.translatesAutoresizingMaskIntoConstraints = false
        leftTabDragger.leadingAnchor.constraint(equalTo: windowDragger.leadingAnchor).isActive = true
        leftTabDragger.topAnchor.constraint(equalTo: windowDragger.topAnchor).isActive = true
        leftTabDragger.bottomAnchor.constraint(equalTo: windowDragger.bottomAnchor).isActive = true
        leftTabDragger.widthAnchor.constraint(equalToConstant: draggerWidth).isActive = true
    }
    
    func setupRightDragger(){
        rightTabDragger.frame = CGRect(x: windowDragger.bounds.width - draggerWidth, y: 0, width: draggerWidth, height: windowDragger.frame.height)
        rightTabDragger.backgroundColor = UIColor.flykBlue
        rightTabDragger.layer.cornerRadius = 4
        rightTabDragger.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        windowDragger.addSubview(rightTabDragger)
        
        
        
        let rightLineOne = UIView(frame: CGRect(x: 2.5, y: rightTabDragger.bounds.height/4, width: 1, height: rightTabDragger.bounds.height/2))
        rightLineOne.backgroundColor = .white
        rightTabDragger.addSubview(rightLineOne)
        
        let rightLineTwo = UIView(frame: CGRect(x: 5, y: (3*rightTabDragger.bounds.height/8), width: 1, height: rightTabDragger.bounds.height/4))
        rightLineTwo.backgroundColor = .white
        rightTabDragger.addSubview(rightLineTwo)
        
        let rightLineThree = UIView(frame: CGRect(x: 7.5, y: rightTabDragger.bounds.height/4, width: 1, height: rightTabDragger.bounds.height/2))
        rightLineThree.backgroundColor = .white
        rightTabDragger.addSubview(rightLineThree)
        
        
        rightTabDragger.translatesAutoresizingMaskIntoConstraints = false
        rightTabDragger.trailingAnchor.constraint(equalTo: windowDragger.trailingAnchor).isActive = true
        rightTabDragger.topAnchor.constraint(equalTo: windowDragger.topAnchor).isActive = true
        rightTabDragger.bottomAnchor.constraint(equalTo: windowDragger.bottomAnchor).isActive = true
        rightTabDragger.widthAnchor.constraint(equalToConstant: draggerWidth).isActive = true
    }
    
    func activate(player: AVPlayer){
        
        let imgGenerator = AVAssetImageGenerator(asset: player.currentItem!.asset)
        let numSamples = 12
        let sampleGap = (player.currentItem?.duration.seconds)! / Double(numSamples)
        for i in 0...(numSamples-1){
            let iTime = CMTime(seconds: Double(i)*sampleGap, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let imageRef = try! imgGenerator.copyCGImage(at: iTime, actualTime: nil)
            let thumbnail = UIImageView(image: UIImage(cgImage:imageRef))
            thumbnailView.addSubview(thumbnail)
            thumbnail.frame = CGRect(x: CGFloat(i)*(thumbnailView.frame.width/CGFloat(numSamples)), y: 0, width: (thumbnailView.frame.width/CGFloat(numSamples)), height: thumbnailView.frame.height)
        }
        
    }
    
    func deactivate(){
        thumbnailView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    
    
}

