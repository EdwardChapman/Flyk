//
//  FourthViewController.swift
//  Flyk
//
//  Created by Edward Chapman on 7/1/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit
import CoreData

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let notificationCellId = "notificationCell"
    let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    


    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Data model: These strings will be the data for the table view cells
    lazy var zeroNotificationsLabel: UILabel = {
        let label = UILabel()
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        label.text = "You don't have any notifications"
        label.textColor = UIColor.flykDarkWhite
        label.isHidden = true
        return label
    }()
    
    lazy var signInView: UIView = {
        let v = UIView()
        self.view.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        
        let label = UILabel()
        v.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50).isActive = true
        label.text = "Sign in to view notifications"
        label.textColor = UIColor.flykDarkWhite
        
        let signInButton = UIButton(frame: .zero)
        v.addSubview(signInButton)
        signInButton.backgroundColor = .flykBlue
        signInButton.layer.cornerRadius = 8
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.widthAnchor.constraint(equalToConstant: 125).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        signInButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
        signInButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        
        
        v.isHidden = true
        
        
        v.bottomAnchor.constraint(equalTo: signInButton.bottomAnchor).isActive = true
        v.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        
        
        
        return v
    }()
    
    @objc func signInButtonTapped(tapGesture: UITapGestureRecognizer) {
        if appDelegate.triggerSignInIfNoAccount(customMessgae: "Sign In To View Notifications") {
            self.signInView.isHidden = true
            
        }
        
    }

    
    
    var notificationList: [NSDictionary] = [] {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.notificationList.count == 0 {
                    self.zeroNotificationsLabel.isHidden = false
                }else{
                    self.zeroNotificationsLabel.isHidden = true
                }
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
            print("Fetch Notifications Status: ", response.statusCode)
            
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
    
    lazy var appDelegate: AppDelegate = {
        let a = UIApplication.shared.delegate as! AppDelegate

        
        
        return a
    }()
    lazy var context = self.appDelegate.persistentContainer.viewContext
    
//    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
//        checkUserSignInStatus()
//    }
    
    
    func checkUserSignInStatusAndFetchNotifications(){
        if appDelegate.currentUserAccount.value(forKey: "signed_in") as! Bool == false {
            DispatchQueue.main.async {
                self.signInView.isHidden = false
            }
        }else{
            DispatchQueue.main.async {
                self.signInView.isHidden = true
                self.tableView.refreshControl!.beginRefreshing()
                self.fetchNotifications()
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkUserSignInStatusAndFetchNotifications()
        addContextObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeContextObserver()
    }
    
    func addContextObserver() {
        self.contextObserverObj = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context, queue: .main){ [unowned self] notification in
             self.checkUserSignInStatusAndFetchNotifications()
        }
    }
    var contextObserverObj: NSObjectProtocol?
    func removeContextObserver() {
        if let obs = self.contextObserverObj {
            NotificationCenter.default.removeObserver(obs)
            self.contextObserverObj = nil
        }
    }
    
    
    
    /* // THIS IS THE ADD A NAVIGATION TITLE AND SHOW NAVIGATION BAR
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
//        self.navigationController?.title = "Notifications
//        self.navigationItem.title = "Notifications"
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if animated {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    */
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchNotifications()
        
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
        tableView.allowsSelection = false
        
        checkUserSignInStatusAndFetchNotifications()
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
        if let notiMsg = self.notificationList[indexPath.row]["message"] as? String {
            cell.notificationLabel.text?.decodeHTML()
        }
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    
}
