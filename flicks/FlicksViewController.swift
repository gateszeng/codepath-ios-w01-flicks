//
//  FlicksViewController.swift
//  flicks
//
//  Created by Gates Zeng on 1/31/17.
//  Copyright © 2017 Gates Zeng. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class FlicksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    let ANIMATE_TIME: TimeInterval = 0.2

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    var filteredMovies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        // initialize the error bar
        errorView.alpha = 0;
        errorView.transform = CGAffineTransform(translationX: 0, y: -40)
        
        // initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        
        // bind action to refresh control
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        // insert control into list
        tableView.insertSubview(refreshControl, at: 0)
        
        // loading the loading HUD before network request
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // grab data from online and populate vars
        makeNetworkRequest(nil)
        
        // customize nav bar
        if let UINavigationBar = navigationController?.navigationBar {
            UINavigationBar.backgroundColor = UIColor(red: 145/255, green: 236/255, blue: 255/255, alpha: 1.0) /* #91ecff */
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeNetworkRequest(_ refreshControl: UIRefreshControl?) {
        // create url for network request
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")!
        
        // create network request
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 2)
        
        // configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            // network request successful
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    self.filteredMovies = self.movies
                    
                    // reload tableView with updated data
                    self.tableView.reloadData()
                }
            }
            // network request failed
            else {
                UIView.animate(withDuration: self.ANIMATE_TIME, animations: {
                    self.errorView.alpha = 1;
                    self.errorView.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }
            
            // hide loading HUD after network request
            MBProgressHUD.hide(for: self.view, animated: true)
            
            // tell refreshControl to stop spinning
            if let refreshControl = refreshControl {
                refreshControl.endRefreshing()
            }

            // set the filteredMovies list
            
        }
        task.resume()
        
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        // animate the refresh icon
        UIView.animate(withDuration: ANIMATE_TIME, animations: {
            self.errorView.alpha = 0;
            self.errorView.transform = CGAffineTransform(translationX: 0, y: -40)
        })
        
        // grab data from network and populate vars
        makeNetworkRequest(refreshControl)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get current cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseURL + posterPath)
            cell.movieView.setImageWith(imageURL as! URL)
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0/255, green: 172/255, blue: 252/255, alpha: 1.0) /* #00acfc */
        cell.selectedBackgroundView = backgroundView
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        print("row \(indexPath.row)")
        return cell
    }

    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            filteredMovies = movies
        } else {
            filteredMovies = searchText.isEmpty ? movies : movies!.filter({ (movie) -> Bool in
                return (movie["title"] as! String).lowercased().hasPrefix(searchText.lowercased())
            })
        }
        tableView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredMovies = movies
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue called")
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
