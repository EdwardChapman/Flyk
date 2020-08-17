//
//  MultipartUpload2.swift
//  Flyk
//
//  Created by Edward Chapman on 8/16/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import Foundation


import UIKit


class ServerUpload_2 {
//    static func profileImgUpload(img: UIImage){
//        let endPointURL = FlykConfig.uploadEndpoint+"/upload"
//        var dataOpt = img.jpegData(compressionQuality: 1)
//        guard let data = dataOpt else { return }
//        
//
//        do {
//            let boundary = "?????"
//            var request = URLRequest(url: URL(string: endPointURL)!)
//            request.timeoutInterval = 660
//            request.httpMethod = "POST"
//            request.httpBody = MultiPartPost_2.photoDataToFormData(data: data, boundary: boundary, fileName: "image") as Data
//            //            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
//            request.addValue("multipart/form-data;boundary=\"" + boundary+"\"",
//                             forHTTPHeaderField: "Content-Type")
//            request.addValue("video/mp4", forHTTPHeaderField: "mimeType")
//            request.addValue(String((request.httpBody! as NSData).length), forHTTPHeaderField: "Content-Length")
//
//            request.addValue("text/plain", forHTTPHeaderField: "Accept")
//
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                print(data, response)
//                if error != nil || data == nil {
//                    print("Client error!")
//                    return
//                }
//
//                guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
//                    print("Server error!")
//                    //                    print(data, response, error)
//                    return
//                }
//                print("SUCCESS")
//            }
//
//            print("Upload Started")
//            task.resume()
//
//        }catch{
//
//        }
//    }
}


class MultiPartPost_2 {
    
    // this is a very verbose version of that function
    // you can shorten it, but i left it as-is for clarity
    // and as an example
    static func photoDataToFormData(data: NSData, boundary: String, fileName: String) -> NSData {
        let fullData = NSMutableData()
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"profilePhoto\"; filename=\"" + fileName + "\"\r\n"
        //        print(lineTwo)
        fullData.append(lineTwo.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: image/jpeg\r\n\r\n"
        fullData.append(lineThree.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        // 4
        fullData.append(data as Data)
        
        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data( using: String.Encoding.utf8, allowLossyConversion: false )!)
    
        
        let end = "--" + boundary + "--\r\n"
        fullData.append(end.data( using: String.Encoding.utf8, allowLossyConversion: false )!)
        
        
        return fullData
    }
}

