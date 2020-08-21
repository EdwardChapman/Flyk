//
//  DiscoverSearchBar.swift
//  Flyk
//
//  Created by Edward Chapman on 7/20/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

class DiscoverSearchController: UISearchController, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("UPDATE SEARCH RESULTS")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        searchBar.delegate = self
    }
    
    
    
    func styleSearchBar(){
        
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .flykDarkWhite
        searchBar.barStyle = .black
//        searchBar.delegate = self
        searchBar.placeholder = "Search"
        //        searchBar.showsCancelButton = true //This shouldn't be necessary.
        
        // self.searchTextField.clearButtonMode = .never //THIS WILL WORK IF I UPGRADE XCODE
//        self.delegate = self
//        self.isActive = true
    }
    /*
    func didDismissSearchController(_ searchController: UISearchController) {
        print("DISMISS")
    }
    func didPresentSearchController(_ searchController: UISearchController) {
        print("DID PRESENT")
    }
    func presentSearchController(_ searchController: UISearchController) {
        print("PRESERNT")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        print("WILL DISMISS")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        print("PRESENT")
    }
*/
    
    /*
    func setupSearchBarConstraints(){
        print(self.intrinsicContentSize.height)
        self.superview?.layoutIfNeeded()
        print(self.intrinsicContentSize.height)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.topAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: self.intrinsicContentSize.height).isActive = true
    }
    */
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    //SearchBarDelegate//////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
//        // THIS IS WHERE WE QUERY WITH THE SEARCH TEXT
//        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
//        print(trimmedSearch)
//    }
//
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(true, animated: true)
//        print("searchbar did begin editing")
//    }
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(false, animated: true)
//        searchBar.text = ""
//        searchBar.endEditing(true)
//        print("searchbar cancel button clicked.")
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.endEditing(true)
//        print("Search bar button clicked.")
//    }
}







/*

class DiscoverSearchBar: UISearchBar, UISearchBarDelegate {
    
    init() {
        super.init(frame: .zero)
        self.searchBarStyle = .minimal
//        self.showsCancelButton = true
        self.tintColor = .flykDarkWhite
        self.barStyle = .black
        self.delegate = self
        self.placeholder = "Search"
        
//        self.searchTextField.clearButtonMode = .never //THIS WILL WORK IF I UPGRADE XCODE
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        // THIS IS WHERE WE QUERY WITH THE SEARCH TEXT
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        print(trimmedSearch)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.setShowsCancelButton(true, animated: true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.setShowsCancelButton(false, animated: true)
        self.text = ""
        self.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.endEditing(true)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(){
        print(self.intrinsicContentSize.height)
        self.superview?.layoutIfNeeded()
        print(self.intrinsicContentSize.height)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.topAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: self.intrinsicContentSize.height).isActive = true
    }

}
*/
