//
//  MenuTargetView.swift
//  Flyk
//
//  Created by Edward Chapman on 7/12/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import Foundation
import UIKit

class MenuTargetView : UIView {
    static let shared = MenuTargetView()
    var viewController : EditVideoViewController?
    var myTargetView: UIView! {
        didSet{
            MenuTargetView.shared.frame = myTargetView.frame
            UIMenuController.shared.setTargetRect(myTargetView.frame, in: myTargetView.superview!)
            MenuTargetView.shared.isHidden = false
        }
    }
    
    private init() {
        super.init(frame: CGRect())
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    @objc func menuWasDismissed(){
        self.isHidden = true
    }
    
    override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(menuWasDismissed),
                name: UIMenuController.didHideMenuNotification,
                object: nil)
            return true
        }else{
            return false
        }
    }
    override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            NotificationCenter.default.removeObserver(self, name: UIMenuController.didHideMenuNotification, object: nil)
            return true
        }else{
            return false
        }
    }
    
    
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let origInteractionValue = myTargetView.isUserInteractionEnabled
        myTargetView.isUserInteractionEnabled = true
        if action == Selector("changeMyTargetViewDuration") {
            myTargetView.isUserInteractionEnabled = origInteractionValue
            return true
        }else if action == Selector("editMyTargetView") && myTargetView.canBecomeFirstResponder {
            myTargetView.isUserInteractionEnabled = origInteractionValue
            return true
        }
        myTargetView.isUserInteractionEnabled = origInteractionValue
        return false
    }
    
    @objc func changeMyTargetViewDuration(){
        if let viewController = self.viewController{
            viewController.changeMyTargetViewDuration()
        }
    }
    @objc func editMyTargetView(){
        if let viewController = self.viewController{
            viewController.editMyTargetView()
        }
    }
    
    @objc func deleteMyTargetView(){
        if let viewController = self.viewController{
            viewController.deleteMyTargetView()
        }
    }
}
