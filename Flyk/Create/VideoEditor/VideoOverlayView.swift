//
//  VideoOverlayView.swift
//  Flyk
//
//  Created by Edward Chapman on 7/11/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//
import UIKit
import Foundation

class VideoOverlayView : UIView, UIGestureRecognizerDelegate {
    init(){
        super.init(frame: CGRect())
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handleBasketItemPan(panGesture:))))
        self.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.handleBasketItemPinch(pinchGesture:))))
        self.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(self.handleBasketItemRotation(rotationGesture:))))
        for ges in self.gestureRecognizers!{
            ges.delegate = self
        }
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            // If the gesture recognizers are on diferent views, do not allow
            // simultaneous recognition.
            if gestureRecognizer.view !== otherGestureRecognizer.view {
                return false
            }
            // If either gesture recognizer is a long press, do not allow
            // simultaneous recognition.
            if gestureRecognizer is UILongPressGestureRecognizer ||
                otherGestureRecognizer is UILongPressGestureRecognizer {
                return false
            }
            
            return true
    }
    
    
    
    
    
    
    
    var initialCenter :CGPoint!
    var panGestureTargetView : UIView!
    @objc func handleBasketItemPan(panGesture: UIPanGestureRecognizer) {
        //        let loc = panGesture.location(in: panGesture.view)
        
        if panGesture.state == .began {
            //            panGesture.isEnabled = false
            //            panGesture.isEnabled = true
            // Save the view's original position.
            panGestureTargetView = panGesture.view?.presentationHitTest(pointLoc: panGesture.location(in: panGesture.view), withinDepth: 1)
            self.initialCenter = panGestureTargetView?.center
        }
        
        if(panGestureTargetView === self){return}
        let translation = panGesture.translation(in: panGestureTargetView?.superview)
        // Update the position for the .began, .changed, and .ended states
        if panGesture.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            panGestureTargetView?.center = newCenter
        }
        else {
            // On cancellation, return the piece to its original location.
            panGestureTargetView?.center = initialCenter
        }
    }
    
    var pinchGestureTargetView : UIView!
    @objc func handleBasketItemPinch(pinchGesture: UIPinchGestureRecognizer){
        
        if pinchGesture.state == .began {
            let loc = pinchGesture.location(in: pinchGesture.view)
            pinchGestureTargetView = pinchGesture.view?.presentationHitTest(pointLoc: loc, withinDepth: 1)
            
        }
        if(pinchGestureTargetView === self){return}
        
        if pinchGesture.state == .began || pinchGesture.state == .changed {
            pinchGestureTargetView!.transform = (pinchGestureTargetView!.transform.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale))
            pinchGesture.scale = 1.0
        }
    }
    
    var rotationGestureTargetView : UIView!
    @objc func handleBasketItemRotation(rotationGesture: UIRotationGestureRecognizer){
        
        if rotationGesture.state == .began {
            let loc = rotationGesture.location(in: rotationGesture.view)
            rotationGestureTargetView = rotationGesture.view?.presentationHitTest(pointLoc: loc, withinDepth: 1)
        }
        
        if(rotationGestureTargetView === self){return}
        
        if rotationGesture.state == .changed {
            rotationGestureTargetView!.transform = rotationGestureTargetView!.transform.rotated(by: rotationGesture.rotation)
            rotationGesture.rotation = 0
        }
    }
    
}
