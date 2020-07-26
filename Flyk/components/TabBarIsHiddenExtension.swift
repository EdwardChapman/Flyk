//
//  TabBarIsHiddenExtension.swift
//  Flyk
//
//  Created by Edward Chapman on 7/26/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
extension UITabBarController{
    func showTabBarView(){
        self.tabBar.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.tabBar.frame = CGRect(x:(self.tabBar.frame.minX), y:(self.view.frame.maxY) - (self.tabBar.frame.height), width:(self.tabBar.frame.width), height: (self.tabBar.frame.height))
        }, completion: { finished in
        })
    }
    
    func hideTabBarView(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.tabBar.frame = CGRect(x:(self.tabBar.frame.minX), y:(self.tabBar.frame.minY) + 100, width:(self.tabBar.frame.width), height: (self.tabBar.frame.height))
        }, completion: { finished in
            self.tabBar.isHidden = true
        })
    }
}
