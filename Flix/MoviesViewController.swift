//
//  MoviesViewController.swift
//  Flix
//
//  Created by Kate Odnous on 7/31/16.
//  Copyright © 2016 Kate Odnous. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  var movies: [NSDictionary]?
  var endpoint: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self

    fetchMoviesInfo();
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
    
    let movie = movies![indexPath.row]
    let title = movie["title"] as? String
    let overview = movie["overview"] as? String
    cell.titleLabel.text = title
    cell.overviewLabel.text = overview
    
    let baseImageURL = "http://image.tmdb.org/t/p/w500/"
    if let posterPath = movie["poster_path"] as? String {
      let posterImageURL = NSURL(string: baseImageURL + posterPath)
      
      // Asynchronously downloads an image from the specified URL,
      //and sets it once the request is finished.
      cell.posterView.setImageWithURL(posterImageURL!)
    }
    
    return cell
  }
  
  func fetchMoviesInfo() {
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
    let request = NSURLRequest(
      URL: url!,
      cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
      timeoutInterval: 10)
    
    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate: nil,
      delegateQueue: NSOperationQueue.mainQueue()
    )
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    let task: NSURLSessionDataTask = session
      .dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
        if let data = dataOrNil {
          if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
            data, options:[]) as? NSDictionary {
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.movies = responseDictionary["results"] as? [NSDictionary]
            self.tableView.reloadData()
          }
        }
      })
    task.resume()
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let cell = sender as! UITableViewCell
    let indexPath = tableView.indexPathForCell(cell)
    let movie = movies![indexPath!.row]
    
    let detailViewController = segue.destinationViewController as! DetailViewController
    detailViewController.movie = movie
  }
}
