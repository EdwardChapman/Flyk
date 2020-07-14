//
//  PresentationHitTest.swift
//  Flyk
//
//  Created by Edward Chapman on 7/12/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func presentationHitTest(pointLoc: CGPoint, withinDepth: Int) -> UIView? {
        if withinDepth == 0 && self.point(inside: pointLoc, with: nil) { return self }
        for subView in self.subviews.reversed() {
            if subView.layer.presentation()!.opacity > Float(0.1) && !subView.isHidden{
                let convertedPoint = self.convert(pointLoc, to: subView)
                if subView.point(inside: convertedPoint, with: nil) {
                    return subView.presentationHitTest(pointLoc: convertedPoint, withinDepth: withinDepth-1)
                }
            }
        }
        if self.point(inside: pointLoc, with: nil) {
            return self
        }else{
            return nil
        }
    }
}
