//
//  DiscoverSearchBar.swift
//  Flyk
//
//  Created by Edward Chapman on 7/20/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class DiscoverSearchBar: UISearchBar, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    weak var discoverVC: DiscoverViewController?
    
    lazy var zeroResultsLabel: UILabel = {
        let label = UILabel()
        self.searchTableView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.searchTableView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: self.searchTableView.topAnchor, constant: 30).isActive = true
        label.text = "No Results"
        label.textColor = UIColor.flykDarkWhite
        label.isHidden = true
        return label
    }()
    
    var searchResultsList: [NSMutableDictionary] = [] {
        didSet {
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
                
                if self.searchResultsList.count == 0 {
                    self.zeroResultsLabel.isHidden = false
                }else{
                    self.zeroResultsLabel.isHidden = true
                }
            }
        }
    }
    
    lazy var searchTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .flykDarkGrey
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "searchCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        
        tableView.isHidden = true
        
        return tableView
    }()
    
    convenience init(searchTableView: UITableView) {
        self.init()
        self.searchTableView = searchTableView
    }

    func styleSearchBar(){
        self.searchBarStyle = .minimal
        self.tintColor = .flykDarkWhite
        self.barStyle = .black
        self.delegate = self
        self.placeholder = "Search"
        self.keyboardAppearance = .dark
    }
    //////////////////////////////////////////////////////////////////////////////////////////////
    //SearchBarDelegate //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        // THIS IS WHERE WE QUERY WITH THE SEARCH TEXT
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        print(trimmedSearch)
        // DO THE SEARCH FETCH HERE.....
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchTableView.isHidden = false
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.endEditing(true)
        self.searchTableView.isHidden = true
        self.searchResultsList = []
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.fetchSearchResults()
        searchBar.endEditing(true)
    }
    
    
    
    
    
    
    

    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResultsList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = (self.searchTableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell?)!
        
        cell.setupNewSearchResult(newSearchResult: self.searchResultsList[indexPath.row])
        return cell
    }
    
    
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let disVC = self.discoverVC {
            let tappedProfileVC = MyProfileVC()
            tappedProfileVC.currentProfileData = self.searchResultsList[indexPath.row]
            disVC.navigationController?.pushViewController(tappedProfileVC, animated: true)
        }
        self.searchTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating && scrollView == self.searchTableView {
            self.endEditing(true)
        }
    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // NETWORKING CALLS //////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    
    func fetchSearchResults() {
        print("Fetching search results")
        
        let searchURL = URL(string: FlykConfig.mainEndpoint+"/search")!
        
        var request = URLRequest(url: searchURL, cachePolicy: .reloadIgnoringLocalCacheData)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: NSDictionary = ["query": self.text]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch let error {
            print(error.localizedDescription)
            return;
        }
        
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { data, response, error in
            
//            DispatchQueue.main.async {
//                self.profileScrollView.refreshControl?.endRefreshing()
//            }
            
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
                if let searchResultsData : [NSDictionary] = try JSONSerialization.jsonObject(with: data!, options: []) as? [NSDictionary] {
                    
                    self.searchResultsList = searchResultsData.map{ dict -> NSMutableDictionary in dict.mutableCopy() as! NSMutableDictionary}
                }
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
            
        }.resume()
    }
}
