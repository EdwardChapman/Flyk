//
//  UploadFiles.swift
//  Flyk
//
//  Created by Edward Chapman on 7/17/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import Foundation

class MultiPartPost {
   




    static func sendFile(
        urlPath:String,
            fileName:String,
                data:NSData,
                completionHandler: @escaping (URLResponse?, NSData?, NSError?) -> Void){
        
        var url: NSURL = NSURL(string: urlPath)!
        var request1: NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        
        request1.httpMethod = "POST"
        
        let boundary = "???????"
        let fullData = photoDataToFormData(data: data, boundary:boundary, fileName:fileName)
        
        request1.setValue("multipart/form-data; boundary=" + boundary,
                          forHTTPHeaderField: "Content-Type")
        
        // REQUIRED!
        request1.setValue(String(fullData.length), forHTTPHeaderField: "Content-Length")
        
        request1.httpBody = fullData as Data
        request1.httpShouldHandleCookies = false
        
        let queue:OperationQueue = OperationQueue()
        
//        NSURLConnection.sendAsynchronousRequest(request1 as URLRequest, queue: queue, completionHandler:completionHandler)
    }

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
        let lineTwo = "Content-Disposition: form-data; name=\"video\"; filename=\"" + fileName + "\"\r\n"
//        print(lineTwo)
        fullData.append(lineTwo.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: video/mp4\r\n\r\n"
        fullData.append(lineThree.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 4
        fullData.append(data as Data)
        
        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.append(lineSix.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        
        
        return fullData
    }
}

