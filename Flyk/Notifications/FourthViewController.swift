//
//  FourthViewController.swift
//  DripDrop
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class FourthViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Data model: These strings will be the data for the table view cells
    let notificationList: [String] = [
        "Bob liked your video",
        "Jeff followed you",
        "Your video reached 100 likes and this line should hopefully spill over this will go to a third line and maybe this will go to a fourth",
        "You reached 100 followers",
        "Smith liked your video"
    ]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let notificationCellId = "notificationCell"
    
    // don't forget to hook this up from the storyboard
    let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        tableView.refreshControl!.translatesAutoresizingMaskIntoConstraints = false
//        tableView.refreshControl!.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 10).isActive = true
//        tableView.refreshControl!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        
    }
    
    @objc func handleRefreshControl() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        //        fetchVideoList()
        // Dismiss the refresh control.
        DispatchQueue.main.async { self.tableView.refreshControl!.endRefreshing() }
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
        cell.notificationLabel.text = self.notificationList[indexPath.row]
//        cell.textLabel?.textColor = .white
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    
}
