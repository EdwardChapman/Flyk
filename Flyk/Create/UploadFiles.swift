//
//  UploadFiles.swift
//  Flyk
//
//  Created by Edward Chapman on 7/17/20.
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
//            print(data, response)
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
        
    }
}


class MultiPartPost {
   
    // this is a very verbose version of that function
    // you can shorten it, but i left it as-is for clarity
    // and as an example
    static func photoDataToFormData(data: NSData, boundary: String, fileName: String, allowComments: Bool, allowReactions: Bool, videoDescription: String) -> NSData {
        let fullData = NSMutableData()
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"video\"; filename=\"" + fileName + "\"\r\n"
//        print(lineTwo)
        fullData.append(lineTwo.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: video/mp4\r\n\r\n"
        fullData.append(lineThree.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        // 4
        fullData.append(data as Data)
        
        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data( using: String.Encoding.utf8, allowLossyConversion: false )!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "\r\n"
        fullData.append(lineSix.data( using: String.Encoding.utf8, allowLossyConversion: false )!)
        
        
        /* VIDEO DESCRIPTION */
        let a = "Content-Disposition: form-data; name=\"videoDescription\"" + "\"\r\n"
        fullData.append(a.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        let aCT = "Content-Type: text/plain\r\n\r\n"
        fullData.append(aCT.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        fullData.append(videoDescription.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        fullData.append(lineFive.data( using: String.Encoding.utf8, allowLossyConversion: false )!)
        
        fullData.append(lineSix.data( using: String.Encoding.utf8, allowLossyConversion: false )!)
        
        
        /* ALLOW COMMENTS */
        let b = "Content-Disposition: form-data; name=\"allowComments\"" + "\"\r\n"
        fullData.append(b.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        let bCT = "Content-Type: text/plain\r\n\r\n"
        fullData.append(bCT.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        fullData.append(allowComments.description.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        fullData.append(lineFive.data( using: String.Encoding.utf8, allowLossyConversion: false )!)
        
        fullData.append(lineSix.data( using: String.Encoding.utf8, allowLossyConversion: false )!)
        
        
        /* ALLOW REACTIONS */
        let c = "Content-Disposition: form-data; name=\"allowReactions\"" + "\"\r\n"
        fullData.append(c.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        let cCT = "Content-Type: text/plain\r\n\r\n"
        fullData.append(cCT.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        fullData.append(allowReactions.description.data( using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        fullData.append(lineFive.data( using: String.Encoding.utf8, allowLossyConversion: false )!)
        
        let end = "--" + boundary + "--\r\n"
        fullData.append(end.data( using: String.Encoding.utf8, allowLossyConversion: false )!)
        
        
        return fullData
    }
}

