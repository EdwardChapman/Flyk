//
//  FirstViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import AVFoundation


class Home: UIViewController {
    
    var startY = CGFloat(0);
    var screenSize: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    var videoPlayerList : [AVPlayerLayer] = []
    
    var carousel : UIScrollView!
    
    func initCarousel(){
        carousel = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.tabBarController!.tabBar.frame.minY))
        carousel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(carousel)
        carousel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        carousel.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        carousel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        carousel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    @objc func handlePan(panGesture: UIPanGestureRecognizer) {
        if(panGesture.state == UIGestureRecognizer.State.began){startY = self.view.frame.origin.y}

        
        if(panGesture.state == UIGestureRecognizer.State.changed){
            var trans = panGesture.translation(in: self.view).y
            var newY = trans + startY
            
            self.view.frame = CGRect(x: self.view.frame.minX, y: newY, width: self.view.frame.width, height: self.view.frame.height)
            
        }
        
        if(panGesture.state == UIGestureRecognizer.State.ended){
            //HERE WE NEED TO SNAP TO A LOCATION
            print("screenHeight: ", screenSize.height)
            let velocity = panGesture.velocity(in: self.view)
//            let slideFactor = velocity.y / 2000
            print("velY: ", velocity.y)
            var decelDist = velocity.y / 3
            print("decelDist: ", decelDist)
            if(decelDist > 0.5 * screenSize.height && decelDist > 0){
                decelDist = 0.5 * screenSize.height
            }else if (decelDist < -0.5 * screenSize.height && decelDist < 0){
                decelDist = -0.5 * screenSize.height
            }
            var projectedY = self.view.frame.minY + decelDist
            
            var floatDiv = abs(projectedY / screenSize.height)
            var modLoc = floatDiv - floor(floatDiv)
            var finalMinY: CGFloat;
            
            
            if(modLoc > 0.5){
                finalMinY = screenSize.height*(-ceil(floatDiv))
            }else{
                finalMinY = screenSize.height*(-floor(floatDiv))
            }
            
            var curVideoIndex = abs(Int(finalMinY/screenSize.height))
            
            if(curVideoIndex < 0){
                curVideoIndex = 0
            }else if (curVideoIndex >= videoPlayerList.count){
                curVideoIndex = videoPlayerList.count - 1
            }
            
            UIView.animate(
                withDuration: Double(0.2),
                delay: 0,
                // 6
                options: .curveEaseOut,
                animations: {
                    self.view.frame = CGRect(x: self.view.frame.minX, y: CGFloat(-curVideoIndex)*self.screenSize.height, width: self.view.frame.width, height: self.view.frame.height)
            })
            
            if(curVideoIndex > 0){videoPlayerList[curVideoIndex-1].player?.pause() }
            videoPlayerList[curVideoIndex].player?.play()
            if(curVideoIndex < videoPlayerList.count-1){videoPlayerList[curVideoIndex+1].player?.pause()}
            print("floatDiv: ", floatDiv, "\n", "floor(floatDiv): ", floor(floatDiv), "\n", "ModLoc: ", modLoc, "\n", "yMin: ", self.view.frame.minY, "\n")
        }
        
    }
    
    
    func getVideos(){
        
        URLSession.shared.dataTask(with: URL(string: "https://swiftytest.uc.r.appspot.com/list/videos")!) { data, response, error in
            
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
                let videoNameList : NSArray = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray
                print(videoNameList)

                for videoName in videoNameList {
                    
                    DispatchQueue.main.async {
                        
                        let player = AVPlayer(url: URL(string: "https://swiftytest.uc.r.appspot.com/videos/"+(videoName as! String))!)
                        let playerLayer = AVPlayerLayer(player: player)
                        playerLayer.frame = CGRect(x: 0, y: self.screenSize.height*CGFloat(self.videoPlayerList.count), width: self.screenSize.width, height: self.screenSize.height)
                        self.view.layer.addSublayer(playerLayer)
                        if(self.videoPlayerList.count == 0){playerLayer.player!.play()}
        
                        self.videoPlayerList.append(playerLayer)
                        self.view.frame = CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: (playerLayer.frame.height*CGFloat(self.videoPlayerList.count)))
                    }
                }
                
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            
            }.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        screenSize = CGRect(x: UIScreen.main.bounds.minX, y: UIScreen.main.bounds.minY, width: UIScreen.main.bounds.width, height: self.view.frame.height - (tabBarController?.tabBar.frame.height)!)

        initCarousel()
//        getVideos()

        
        
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan)))
    }
    


}

