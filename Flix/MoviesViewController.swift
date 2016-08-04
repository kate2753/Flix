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

class MoviesViewController: UIViewController,
  UITableViewDataSource, UITableViewDelegate,
  UICollectionViewDataSource, UICollectionViewDelegate,
UISearchBarDelegate {
  
  @IBOutlet weak var moviesViewSegmentedControl: UISegmentedControl!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var networkErrorView: UIView!
  @IBOutlet weak var searchBarView: UISearchBar!
  
  var movies: [NSDictionary]?
  var filteredMovies: [NSDictionary]?
  var searchText: String = ""
  
  var endpoint: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    collectionView.delegate = self
    collectionView.dataSource = self
    searchBarView.delegate = self
    
    // Set up and attach refresh control to the table view
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(fetchMoviesInfo(_:)), forControlEvents: UIControlEvents.ValueChanged)
    tableView.insertSubview(refreshControl, atIndex: 0)
    
    //Show list view by default (hide grid view)
    tableView.hidden = false
    collectionView.hidden = !tableView.hidden
    //Hide network error by default
    networkErrorView.hidden = true
    
    fetchMoviesInfo(nil);
  }
  
  @IBAction func onMoviesViewChange(sender: AnyObject) {
    let isListView = moviesViewSegmentedControl.selectedSegmentIndex == 0
    tableView.hidden = !isListView
    collectionView.hidden = !tableView.hidden
    reloadCurrentViewData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredMovies?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
    
    let movie = filteredMovies![indexPath.row]
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
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filteredMovies?.count ?? 0
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionViewCell", forIndexPath: indexPath) as! MovieCollectionViewCell
    
    print(cell)
    
    let movie = movies![indexPath.row]
    
    let baseImageURL = "http://image.tmdb.org/t/p/w500/"
    if let posterPath = movie["poster_path"] as? String {
      let posterImageURL = NSURL(string: baseImageURL + posterPath)
      
      // Asynchronously downloads an image from the specified URL,
      //and sets it once the request is finished.
      cell.posterImageView.setImageWithURL(posterImageURL!)
    }
    return cell
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    self.searchText = searchText
    filterMovies()
  }
  
  func fetchMoviesInfo(refreshControl: UIRefreshControl?) {
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
    
    if refreshControl == nil {
      MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    let task: NSURLSessionDataTask = session
      .dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
        self.networkErrorView.hidden = true
        if let refreshControl = refreshControl {
          refreshControl.endRefreshing()
        } else {
          MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
        
        if let error = error {
          if error.domain == "NSURLErrorDomain" {
            self.networkErrorView.hidden = false
          }
        } else if let data = dataOrNil {
          if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
            data, options:[]) as? NSDictionary {
            self.movies = responseDictionary["results"] as? [NSDictionary]
            self.filterMovies()
          }
        }
      })
    task.resume()
  }
  
  func reloadCurrentViewData() {
    if moviesViewSegmentedControl.selectedSegmentIndex == 0 {
      self.tableView.reloadData()
    } else {
      self.collectionView.reloadData()
    }
  }
  
  func filterMovies() {
    if searchText.isEmpty || movies == nil {
      filteredMovies = movies
    } else {
      filteredMovies = movies!.filter({(movie: NSDictionary) -> Bool in
        let title = movie["title"] as? String
        if let title = title {
          return title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        }
        return false
      })
    }
    
    reloadCurrentViewData()
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    var indexPath:NSIndexPath?
    if let cell = sender as? UITableViewCell {
      indexPath = tableView.indexPathForCell(cell)
    } else if let cell = sender as? UICollectionViewCell {
      indexPath = collectionView.indexPathForCell(cell)
    }
    let movie = movies![indexPath!.row]
    let detailViewController = segue.destinationViewController as! DetailViewController
    detailViewController.movie = movie
  }
}
