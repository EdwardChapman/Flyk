//
//  FifthViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

var profileImage: UIImageView!
var videoScrollView : UIScrollView!
var usernameTextView : UITextView!
var bioTextView : UITextView!

func loadProfileImage(profileImgString: String){
    let pImgURL = URL(string: "https://swiftytest.uc.r.appspot.com/profilePhotos/"+profileImgString)!
    print(pImgURL)
    URLSession.shared.dataTask(with:  pImgURL, completionHandler: { data, response, error in
        DispatchQueue.main.async {
            print(data)
            profileImage.image = UIImage(data: data!)
        }
    }).resume()
    
}

func getMyProfile() {
    
    URLSession.shared.dataTask(with: URL(string: "https://swiftytest.uc.r.appspot.com/myProfile/")!) { data, response, error in
        
        if error != nil || data == nil {
            print("Client error!")
            return
        }
        
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            print("Server error!")
            return
        }
        
        guard let mime = response.mimeType, mime == "application/json" else {
            print("Wrong MIME type!")
            return
        }
        
        do {
            let myProfileData : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
//            {
//                username: "Mr. Polar Bear",
//                profile_photos: "polar_bear.jpg",
//                videos: [
//                "v09044e20000brmcq2ihl9acefv17icg.MP4",
//                "v09044fa0000brfud6gpfrijil1melq0.MP4"
//                ],
//                bio: "I am a polar bear."
//            }
            print(myProfileData)
            
            loadProfileImage(profileImgString: myProfileData["profile_photos"] as? String ?? "default.png")
            
            DispatchQueue.main.async {
                usernameTextView.text = myProfileData["username"] as? String
                bioTextView.text = myProfileData["bio"] as? String
            }
            

        } catch {
            print("JSON error: \(error.localizedDescription)")
        }
        
        }.resume()
}



class MyProfile: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMyProfile()
        
        profileImage = UIImageView(frame: CGRect(x: 25, y: 50, width: 100, height: 100))
        profileImage.layer.cornerRadius = profileImage.frame.width/2;
        profileImage.layer.masksToBounds = true;
        profileImage.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        self.view.addSubview(profileImage)
        
        usernameTextView = UITextView(frame: CGRect(x: 25, y: 170, width: self.view.frame.width - 100, height: 30))
        self.view.addSubview(usernameTextView)
        
        bioTextView = UITextView(frame: CGRect(x: 25, y: 220, width: self.view.frame.width - 100, height: 100))
        self.view.addSubview(bioTextView)
        videoScrollView = UIScrollView(frame: CGRect(x: 0, y: 400, width: self.view.frame.width, height: 400))
        self.view.addSubview(videoScrollView)
        
        
    }
    
    
}
