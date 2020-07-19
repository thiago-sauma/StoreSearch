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
            if searchResults[indexPath.row].artist.isEmpty{
                cell.artistNameLabel.text = "Unknown"
            }else{
                cell.artistNameLabel.text = "\(searchResults[indexPath.row].artist) (\(searchResults[indexPath.row].type))"
            }
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
        if !searchBar.text!.isEmpty{ //isEmpty = ""
            searchBar.resignFirstResponder() //teclado se esconde ate se clicar no botao de Search novamente
            self.hasSearched = true
            self.searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!)
            guard let data = self.performStoreRequest(with: url) else {return} //retorna algo em bytes
            self.searchResults = self.parse(data: data)
           // self.searchResults.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending}
            self.searchResults.sort {$0 < $1}
            self.tableView.reloadData()
        }
    }
}

//MARK:- NETWORKING METHODS
extension SearchViewController{
    
//PASSO 1
    func iTunesURL (searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!
        //codifica o texto para na ter problemas com caracteres especiais, como espacos etc.
        let urlString = "https://itunes.apple.com/search?term=\(encodedText)"
        let url = URL(string: urlString)
        return url!
    }
    
    //PASSO 2
    func performStoreRequest(with url: URL) -> Data?{
        do {
           let data =  try Data(contentsOf: url)
            print (data)
            return data
        } catch  {
            print ("Download Error: \(error.localizedDescription)")
            self.showNetworkError()
            return nil
        }
    }
    
    //PASSO 3
    func parse (data: Data) -> [SearchResult]{

        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch  {
            print ("JSON Erro: \(error)")
            return []
        }
    }
    
}


  //MARK:- HELPER METHODS
extension SearchViewController{
   
    func showNetworkError(){
        let alert = UIAlertController(title: "Whooops...", message: "There was an error accessing Itunes Store", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
   
}
