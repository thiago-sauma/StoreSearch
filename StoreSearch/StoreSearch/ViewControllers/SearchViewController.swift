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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchBar()
        self.setupTableview()
    }
    
    @IBAction func segmentedChanged (_ sender: UISegmentedControl){
        self.performSearchUrlSessionRequest()
    }
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
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
        let nibLoading = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        self.tableView.register(nibLoading, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }else if !hasSearched{
            return 0
        }else if self.searchResults.count == 0{
            return 1
        } else{
            return self.searchResults.count 
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }else{
            if self.searchResults.count == 0 {
                return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCellTableViewCell
                cell.configCell(with: searchResults[indexPath.row])
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading{
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
        //self.dataMethodRequest(searchBar)
        self.performSearchUrlSessionRequest()
    }
    
    func performSearchUrlSessionRequest(){
        if !searchBar.text!.isEmpty{ //isEmpty = ""
            searchBar.resignFirstResponder() //teclado se esconde ate se clicar no botao de Search novamente
            self.dataTask?.cancel() //se tem dataTask ativa, cancele-a para evitar um segundo request por cima do primeiro
            self.isLoading = true
            self.tableView.reloadData()
            self.hasSearched = true
            self.searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!)
            self.dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                if let error = error as NSError?,
                        error.code != -999{
                    DispatchQueue.main.async {
                        self.hasSearched = false
                        self.isLoading = false
                        self.tableView.reloadData()
                        self.showNetworkError()
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        print("hhtResponse: \(String(describing: response))")
                    return}
                print (httpResponse)
                
                guard let data = data else {return}
                self.searchResults = self.parse(data: data)
                self.searchResults.sort(by: {$0<$1 })
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView.reloadData()
                }
            })
            self.dataTask?.resume()
            
        }
        
    }

    
//    func dataMethodRequest(_ searchBar: UISearchBar){
//        if !searchBar.text!.isEmpty{ //isEmpty = ""
//            searchBar.resignFirstResponder() //teclado se esconde ate se clicar no botao de Search novamente
//            self.isLoading = true
//            self.tableView.reloadData()
//            self.hasSearched = true
//            self.searchResults = []
//            //putting the request in a background thread
//            let url = iTunesURL(searchText: searchBar.text!) //elementos de interface tem q ficar fora de threads secundarias
//            DispatchQueue.global().async{
//                guard let data = self.performStoreRequest(with: url) else {return} //retorna algo em bytes
//                self.searchResults = self.parse(data: data)
//                // self.searchResults.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending}
//                self.searchResults.sort {$0 < $1}
//                DispatchQueue.main.async { //mudancas na interface DEVEM acontecer na main thread
//                    self.isLoading = false
//                    self.tableView.reloadData()
//                }
//            }
//        }
//
//    }
    

    
   
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

//MARK:- DATA REQUEST METHOD
extension SearchViewController{
    
//    //PASSO 1
//    func iTunesURL (searchText: String) -> URL {
//        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!
//        //codifica o texto para na ter problemas com caracteres especiais, como espacos etc.
//        let urlString = "https://itunes.apple.com/search?term=\(encodedText)&limit=20"
//        let url = URL(string: urlString)
//        return url!
//    }
    
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

//MARK:- URLSESSION METHOD
extension SearchViewController{
        //PASSO 1
    func iTunesURL (searchText: String) -> URL {
        let kindFiltered: String
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            kindFiltered = "musicTrack"
        case 2:
            kindFiltered = "software"
        case 3:
            kindFiltered = "ebook"
        default:
            kindFiltered = ""
        }
            let encodedText = searchText.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!
            //codifica o texto para na ter problemas com caracteres especiais, como espacos etc.
            let urlString = "https://itunes.apple.com/search?term=\(encodedText)&limit=20&entity=\(kindFiltered)"
            let url = URL(string: urlString)
            return url!
        }

}

