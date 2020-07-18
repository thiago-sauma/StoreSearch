//
//  ViewController.swift
//  StoreSearch
//
//  Created by Thiago on 7/17/20.
//  Copyright © 2020 Curso IOS. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults = [SearchResult]()
    var hasSearched = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchBar()
        self.setupTableview()
    }
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
        }
    }
    
}

//MARK:- TABLE VIEW METHODS
extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func setupTableview(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nibCell = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        self.tableView.register(nibCell, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        let nibCellNothingFound = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        self.tableView.register(nibCellNothingFound, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched{
            return 0
        }else if self.searchResults.count == 0{
            return 1
        } else{
            return self.searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCellTableViewCell
            cell.nameLabel.text = searchResults[indexPath.row].name
            cell.artistNameLabel.text = searchResults[indexPath.row].artistName
            return cell
        }
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0{
            return nil
        }else{
            return indexPath
        }
    }
}

//MARK:- SEARCH BAR  METHODS
extension SearchViewController: UISearchBarDelegate{
    
    func setupSearchBar (){
        self.searchBar.placeholder = "App name, artist, song, album, e-book"
        self.searchBar.delegate = self
        self.searchBar.becomeFirstResponder()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition { //unifica a status bar area com a search bar, eliminando o gap de cor
        return .topAttached
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() //teclado se esconde ate se clicar no botao de Search novamente
        self.searchResults = []
        if searchBar.text! != "a"{
            for i in 0...2{
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake result %d for", i)
                searchResult.artistName = searchBar.text!
                self.searchResults.append(searchResult)
            }
        }
        self.hasSearched = true
        self.tableView.reloadData()
    }
    

}
