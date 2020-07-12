//
//  BasketView.swift
//  Flyk
//
//  Created by Edward Chapman on 7/12/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import Foundation
import UIKit


class BasketView : UIView{
    
    override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set(shouldHide) {
            super.isHidden = shouldHide
            self.superview!.bringSubviewToFront(self)
            var newBasketContainerY = (self.superview?.frame.maxY)! - self.frame.height
            if(shouldHide){ newBasketContainerY = (self.superview?.frame.maxY)! }
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.frame = CGRect(x: self.frame.minX, y: newBasketContainerY, width: self.frame.width, height: self.frame.width)
            }, completion: { finished in
                
            })
        }
    }
    
    let viewController : EditVideoViewController!
    
    init(viewController: EditVideoViewController){
        let superFrame = viewController.view.frame
        self.viewController = viewController
        super.init(frame: CGRect(
            x: superFrame.minX,
            y: superFrame.maxY * 0.55,
            width: superFrame.width,
            height: superFrame.maxY - superFrame.maxY * 0.55)
        )
        viewController.view.addSubview(self)
        self.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        self.layer.cornerRadius = 38
        self.isHidden = true
        setupBasketButton()
        setupBasketItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBasketButton(){
        let basketButton = UIImageView(image: UIImage(named: "basketV2"))
        basketButton.frame = CGRect(x: 25, y: self.superview!.frame.maxY - 80, width: 50, height: 50)
        basketButton.contentMode = .scaleAspectFit
        basketButton.isUserInteractionEnabled = true
        self.superview!.addSubview(basketButton)
        basketButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBasketTap(tapGesture:))))
    }
    
    func setupBasketItems(){
        let addText = UIImageView(image: UIImage(named: "T"))
        addText.layer.name = "addText"
        addText.frame = CGRect(x: 20, y: 20, width: 50, height: 50)
        addText.contentMode = .scaleAspectFit
        addText.isUserInteractionEnabled = true
        addText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBasketItemTap(tapGesture:))))
        self.addSubview(addText)
    }

    
    
    
    
    @objc func handleBasketTap(tapGesture: UITapGestureRecognizer) {
        self.isHidden = false
    }
    
    @objc func handleBasketItemTap(tapGesture: UITapGestureRecognizer) {
        self.isHidden = true
        
        
        // ACTUALLY THIS SHOULD JUST COPY THE VIEW IT IS PASSED........
        // IN THE CASE OF TEXT IT SHOULD BE A UITEXTVIEW? OR CATEXTLAYER
        if(tapGesture.view!.layer.name == "addText"){
            
            
            let textview = UITextField()
            textview.layer.opacity = 1
            textview.backgroundColor = .red
            textview.text = "TEXT"
            textview.font = textview.font!.withSize(50)
            textview.textColor = .white
            //            textview.becomeFirstResponder()
            viewController.videoOverlayView.addSubview(textview)
            
            textview.frame = CGRect(origin: CGPoint(x: 0, y: 300), size: textview.attributedText!.size())
            textview.center.x = viewController.videoOverlayView.center.x
            
            textview.delegate = viewController.textEditorView
            
            
            viewController.textEditorView.beginEditing(textField: textview)
            
            
        }
        
    }
}
