//
//  Settings.swift
//  Flyk
//
//  Created by Edward Chapman on 8/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    
    var settingsList = [
        (
            title: "Privacy Policy",
            action: {
                if let url = URL(string: FlykConfig.mainEndpoint+"/privacy") {
                    UIApplication.shared.open(url)
                }
            },
            textColor: nil,
            shouldDisplayArrow: true
        ),
        (
            title: "Terms & Conditions",
            action: {
                if let url = URL(string: FlykConfig.mainEndpoint+"/terms") {
                    UIApplication.shared.open(url)
                }
            },
            textColor: nil,
            shouldDisplayArrow: true
        ),
        (
            title: "Logout",
            action: {
                print("LOGOUT")
            },
            textColor: UIColor.red,
            shouldDisplayArrow: false
        )
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = .flykDarkGrey
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = .flykDarkGrey
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .flykDarkWhite
        
    }
    
    var previousInteractivePopGestureDelegate: UIGestureRecognizerDelegate?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //We store the navigation controllers interactive pop delegate before removing it
        //We will place it back during viewWillDissappear
        if animated {
            if let rootVC = self.navigationController?.viewControllers[0] {
                if rootVC != self {
                    previousInteractivePopGestureDelegate = self.navigationController?.interactivePopGestureRecognizer?.delegate
                    self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if animated {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.interactivePopGestureRecognizer?.delegate = previousInteractivePopGestureDelegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .flykDarkGrey
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        tableView.backgroundColor = .flykDarkGrey
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        
//        tableView.refreshControl = UIRefreshControl()
//        tableView.refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        self.title = "Settings"

//        let cellTableViewHeader = tableView.dequeueReusableCellWithIdentifier(TableViewController.tableViewHeaderCustomCellIdentifier) as! UITableViewCell
//
//        cellTableViewHeader.frame = CGRectMake(0, 0, self.tableView.bounds.width, self.heightCache[TableViewController.tableViewHeaderCustomCellIdentifier]!)
//        self.tableView.tableHeaderView = cellTableViewHeader
//
//        // We set the table view footer, just know that it will also remove extra cells from tableview.
//        let cellTableViewFooter = tableView.dequeueReusableCellWithIdentifier(TableViewController.tableViewFooterCustomCellIdentifier) as! UITableViewCell
//        cellTableViewFooter.frame = CGRectMake(0, 0, self.tableView.bounds.width, self.heightCache[TableViewController.tableViewFooterCustomCellIdentifier]!)
//        self.tableView.tableFooterView = cellTableViewFooter
//        tableView.allowsSelection = false
//        self.tableView.refreshControl!.beginRefreshing()
//        fetchNotifications()
        
//        let logoutButton = UIButton(type: .custom)
//        logoutButton.setTitle("Logout", for: .normal)
//        logoutButton.backgroundColor = .red
//        logoutButton.layer.cornerRadius = 45/2
//        logoutButton.setTitleColor(.white, for: .normal)
//        self.view.addSubview(logoutButton)
//        logoutButton.translatesAutoresizingMaskIntoConstraints = false
//        logoutButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        logoutButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
//        logoutButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
//        logoutButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
//        logoutButton.addTarget(self, action: #selector(handleLogoutTap), for: .touchUpInside)
        
    }
    
    @objc func handleLogoutTap(sender: UIButton, forEvent event: UIEvent){
        //NETWORK CALL TO LOGOUT HERE
        print("LOGOUT")
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //TABLEVIEW DELEGATE //////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////
    
//    @objc func handleRefreshControl() {
//        let generator = UIImpactFeedbackGenerator(style: .medium)
//        generator.impactOccurred()
//        //        fetchVideoList()
//        // Dismiss the refresh control.
////        self.fetchNotifications()
//
//    }
    
    // number of rows in table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsList.count
    }
    
    // create a cell for each table view row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
//        let cell = (self.tableView.dequeueReusableCell(withIdentifier: notificationCellId) as! NoticationCell?)!
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "settingCell")!
        let curSetting = settingsList[indexPath.row]
        if curSetting.shouldDisplayArrow {
            cell.accessoryType = .disclosureIndicator
        }else {
            cell.accessoryType = .none
        }
            
        cell.backgroundColor = .clear
        if let titleColour = curSetting.textColor {
            cell.textLabel?.textColor = titleColour
        }else{
            cell.textLabel?.textColor = .flykDarkWhite
        }
        // set the text from the data model
        //        cell.backgroundColor = .flykDarkGrey
        cell.textLabel?.text = settingsList[indexPath.row].title
        //        cell.textLabel?.textColor = .white
        return cell
    }
    
    // method to run when table view cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("You tapped cell number \(indexPath.row).")
        settingsList[indexPath.row].action()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
}
