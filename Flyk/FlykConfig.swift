//
//  FlykConfig.swift
//  Flyk
//
//  Created by Edward Chapman on 8/2/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class FlykConfig {
    //THESE MUST BE CHANGED BEFORE SUBMISSION TO THE ACTUAL ONES
    static let mainEndpoint = "https://swiftytest.uc.r.appspot.com"
    static let uploadEndpoint = "https://upload-dot-swiftytest.uc.r.appspot.com"
    
    
    
    static let defaultProfileImage: UIImage = {
        let img = UIImage(named: "newPlaceholderProfileImageV1")!
//        let tintedImage = img.withRenderingMode(.alwaysTemplate)
        //^^This would allow the image to be tinted by uiimageview
       return img
    }()
}
