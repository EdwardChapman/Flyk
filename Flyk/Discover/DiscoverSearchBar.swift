//
//  DiscoverSearchBar.swift
//  Flyk
//
//  Created by Edward Chapman on 7/20/20.
//  Copyright © 2020 Edward Chapman. All rights reserved.
//

import UIKit

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
