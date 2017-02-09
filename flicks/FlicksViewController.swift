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

class FlicksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let ANIMATE_TIME: TimeInterval = 0.2

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    var movies: [NSDictionary]?
    var endpoint: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
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
        
        // create url for network request
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")!
        
        // create network request
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 2)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as! [NSDictionary]
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
            
            // Hide loading HUD after network request
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        UIView.animate(withDuration: ANIMATE_TIME, animations: {
            self.errorView.alpha = 0;
            self.errorView.transform = CGAffineTransform(translationX: 0, y: -40)
        })
        
        // constants for grabbing info from api
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")!
        
        // create a  network request
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        // configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            // network request successful
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    
                    // reload tableView with updated data
                    self.tableView.reloadData()
                }
            }
            // network request failed
            else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.errorView.alpha = 1;
                    self.errorView.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }
            
            // tell refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseURL + posterPath)
            cell.movieView.setImageWith(imageURL as! URL)
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        print("row \(indexPath.row)")
        return cell
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
