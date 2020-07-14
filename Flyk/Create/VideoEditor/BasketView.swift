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
            if !shouldHide {super.isHidden = shouldHide}
            self.superview!.bringSubviewToFront(self)
            var newBasketContainerY = (self.superview?.frame.maxY)! - self.frame.height
            if(shouldHide){ newBasketContainerY = (self.superview?.frame.maxY)! }
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.frame = CGRect(x: self.frame.minX, y: newBasketContainerY, width: self.frame.width, height: self.frame.width)
            }, completion: { finished in
                if shouldHide {super.isHidden = shouldHide}
            })
        }
    }
    
    
    
    init(superview: UIView){
        let superFrame = superview.frame
        
        super.init(frame: CGRect(
            x: superFrame.minX,
            y: superFrame.maxY,
            width: superFrame.width,
            height: superFrame.maxY - superFrame.maxY * 0.55)
        )
        self.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        self.layer.cornerRadius = 38
        super.isHidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getBasketButton() -> UIImageView{
        let basketButton = UIImageView(image: UIImage(named: "basketV2"))
        basketButton.frame = CGRect(x: 25, y: self.superview!.frame.maxY - 80, width: 50, height: 50)
        basketButton.contentMode = .scaleAspectFit
        basketButton.isUserInteractionEnabled = true
        basketButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBasketTap(tapGesture:))))
        return basketButton
    }
    
    func getBasketItems() -> [UIView]{
        var itemList: [UIView] = []
        let addText = UIImageView(image: UIImage(named: "T"))
        addText.layer.name = "addText"
        addText.frame = CGRect(x: 20, y: 20, width: 50, height: 50)
        addText.contentMode = .scaleAspectFit
        addText.isUserInteractionEnabled = true
        itemList.append(addText)
        return itemList
    }


    @objc func handleBasketTap(tapGesture: UITapGestureRecognizer) {
        self.isHidden = false
    }
    
    
    
    func createTextField() -> UITextField {
        let textField = UITextField()
        textField.layer.opacity = 1
        textField.backgroundColor = .red
        textField.text = "TEXT"
        textField.font = textField.font!.withSize(50)
        textField.textColor = .white
        var textViewSizeWithText =  textField.attributedText!.size()
        textViewSizeWithText.width = 2
        textField.text = ""
        textField.frame = CGRect(origin: CGPoint(x: 0, y: 300), size: textViewSizeWithText)
        textField.layer.cornerRadius = 8
        return textField
    }
    
}
