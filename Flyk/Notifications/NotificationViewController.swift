//
//  FourthViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let notificationCellId = "notificationCell"
    let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    
    // Data model: These strings will be the data for the table view cells
    var notificationList: [NSDictionary] = [] {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchNotifications(){
        var request = URLRequest(url: URL(string: FlykConfig.mainEndpoint + "/notifications")!)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.tableView.refreshControl!.endRefreshing() }
            if(error != nil) {return print(error)}
            
            guard let response = response as? HTTPURLResponse
                else{print("resopnse is not httpurlResponse"); return;}
            print("Status: ", response.statusCode)
            
            if response.statusCode == 200 {
                guard let mime = response.mimeType, mime == "application/json" else {
                    print("Wrong MIME type!")
                    return;
                }
                do {
                    let json : [NSDictionary] = try JSONSerialization.jsonObject(with: data!, options: []) as! [NSDictionary]
                    self.notificationList = json
                } catch let err {
                    print("JSON error: \(err.localizedDescription)")
                }
            }
            
            if response.statusCode == 500 {
                print("Server Error")
            }
            
            if response.statusCode == 400 {
                print("Client Error")
               
            }
            }.resume()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotifications()
        
        // Register the table view cell class and its reuse id
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(tableView)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .flykDarkGrey
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(NoticationCell.self, forCellReuseIdentifier: notificationCellId)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        
    }
    
    @objc func handleRefreshControl() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        //        fetchVideoList()
        // Dismiss the refresh control.
        self.fetchNotifications()
//        DispatchQueue.main.async { self.tableView.refreshControl!.endRefreshing() }
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = (self.tableView.dequeueReusableCell(withIdentifier: notificationCellId) as! NoticationCell?)!
        
        // set the text from the data model
//        cell.backgroundColor = .flykDarkGrey
        cell.notificationLabel.text = self.notificationList[indexPath.row]["message"] as! String
//        cell.textLabel?.textColor = .white
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    
}
