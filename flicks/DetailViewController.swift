//
//  DetailViewController.swift
//  flicks
//
//  Created by Gates Zeng on 2/7/17.
//  Copyright © 2017 Gates Zeng. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageURL = NSURL(string: baseURL + posterPath)
            posterImageView.setImageWith(imageURL as! URL)
        }
        
        let smallBaseURL = "https://image.tmdb.org/t/p/w45"
        let largeBaseURL = "https://image.tmdb.org/t/p/original"
        if let posterPath = movie["poster_path"] as? String {
            let smallImageURL = URL(string: smallBaseURL + posterPath)
            let largeImageURL = URL(string: largeBaseURL + posterPath)
            
            let smallImageRequest = NSURLRequest(url: smallImageURL!)
            let largeImageRequest = NSURLRequest(url: largeImageURL!)
            
            self.posterImageView.setImageWith(
                smallImageRequest as URLRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = smallImage;
                    
                    self.setLargeImage(largeImageRequest: largeImageRequest, placeholder: smallImage)
                    
                },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
                    self.setLargeImage(largeImageRequest: largeImageRequest, placeholder: #imageLiteral(resourceName: "poster_placeholder"))
            })
        }
        
        self.navigationItem.title = title
        
        print(movie)
    }
    
    func setLargeImage(largeImageRequest: NSURLRequest, placeholder: UIImage) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            self.posterImageView.alpha = 1.0
            
            }, completion: { (sucess) -> Void in
                
                // The AFNetworking ImageView Category only allows one request to be sent at a time
                // per ImageView. This code must be in the completion block.
                self.posterImageView.setImageWith(
                    largeImageRequest as URLRequest,
                    placeholderImage: placeholder,
                    success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                        
                        self.posterImageView.image = largeImage;
                        
                    },
                    failure: { (request, response, error) -> Void in
                        // do something for the failure condition of the large image request
                        // possibly setting the ImageView's image to a default image
                        self.posterImageView.image = #imageLiteral(resourceName: "poster_placeholder");
                        
                })
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
