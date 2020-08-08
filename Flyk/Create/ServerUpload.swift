//
//  ServerUpload.swift
//  Flyk
//
//  Created by Edward Chapman on 7/27/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class ServerUpload {
    static func videoUpload(videoUrl: URL, allowComments: Bool, allowReactions: Bool, videoDescription: String){
        let endPointURL = FlykConfig.uploadEndpoint+"/upload"
        //        let img = UIImage(contentsOfFile: fullPath)
        var data: NSData;
        do {
            try data = NSData(contentsOf: videoUrl)
        }catch{
            print("URL FAIL")
            return
        }
        
        
        do {
            let boundary = "?????"
            var request = URLRequest(url: URL(string: endPointURL)!)
            request.timeoutInterval = 660
            request.httpMethod = "POST"
            request.httpBody = MultiPartPost.photoDataToFormData(data: data, boundary: boundary, fileName: "video", allowComments: allowComments, allowReactions: allowReactions, videoDescription: videoDescription) as Data
            //            request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            request.addValue("multipart/form-data;boundary=\"" + boundary+"\"",
                             forHTTPHeaderField: "Content-Type")
            request.addValue("video/mp4", forHTTPHeaderField: "mimeType")
            request.addValue(String((request.httpBody! as NSData).length), forHTTPHeaderField: "Content-Length")
            
            request.addValue("text/plain", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                print(data, response)
                if error != nil || data == nil {
                    print("Client error!")
                    return
                }
                
                guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
                    print("Server error!")
                    //                    print(data, response, error)
                    return
                }
                print("SUCCESS")
            }
            
            print("Upload Started")
            task.resume()
            
        }catch{
            
        }
    }
}
