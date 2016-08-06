//
//  DetailViewController.swift
//  Flix
//
//  Created by kate_odnous on 8/2/16.
//  Copyright © 2016 Kate Odnous. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {

  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var infoView: UIView!

  var movie: NSDictionary!
  var fullScreenPosterImageView: UIImageView?

  override func viewDidLoad() {
    super.viewDidLoad()

    scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)

    let title = movie["title"] as? String
    let overview = movie["overview"] as? String
    titleLabel.text = title
    overviewLabel.text = overview
    overviewLabel.sizeToFit()

    let baseImageURL = "http://image.tmdb.org/t/p/"
    let lowResImageSize = "w92/"
    let highResImageSize = "original/"
    if let posterPath = movie["poster_path"] as? String {
      ViewHelper.loadImageLowHiRes(posterImageView,
                                   lowResImageURL: baseImageURL + lowResImageSize + posterPath,
                                   hiResImageURL: baseImageURL + highResImageSize + posterPath)
    }

    let posterImageGestureRecognazier = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.posterImageTapped))
    posterImageGestureRecognazier.numberOfTapsRequired = 1
    posterImageGestureRecognazier.numberOfTouchesRequired = 1
    posterImageView.addGestureRecognizer(posterImageGestureRecognazier)
  }

  @IBAction func posterImageTapped(sender: UITapGestureRecognizer) {
    // Create a new UIScrollView and image that take up full screen
    // let fullScreenUIScrollView = UIScrollView()
    let originalPosterImageView = sender.view as? UIImageView
    if let originalPosterImageView = originalPosterImageView {
      fullScreenPosterImageView = UIImageView(image: originalPosterImageView.image)
      fullScreenPosterImageView!.frame = self.view.frame
      fullScreenPosterImageView?.backgroundColor = .blackColor()
      fullScreenPosterImageView?.contentMode = .ScaleAspectFit
      fullScreenPosterImageView?.userInteractionEnabled = true

      let fullScreenUIScrollView = UIScrollView()

      let fullScreenPosterTap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.dismissFullScreenImage))
      fullScreenUIScrollView.addGestureRecognizer(fullScreenPosterTap)

      fullScreenUIScrollView.backgroundColor = UIColor.blackColor()

      fullScreenUIScrollView.delegate = self
      fullScreenUIScrollView.minimumZoomScale = 0.25
      fullScreenUIScrollView.maximumZoomScale = 2

      fullScreenUIScrollView.contentSize = fullScreenPosterImageView!.image!.size
      fullScreenUIScrollView.addSubview(fullScreenPosterImageView!)
      fullScreenUIScrollView.zoomScale = 0.5


      let app = UIApplication.sharedApplication()
      if let keyWindow = app.keyWindow {
        fullScreenUIScrollView.frame = keyWindow.frame
        fullScreenPosterImageView?.frame = keyWindow.frame
        keyWindow.addSubview(fullScreenUIScrollView)
      }
    }

    // Add tap gesture recognizer to remove full screen view when user taps on the image again
  }

  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return fullScreenPosterImageView
  }

  @IBAction func dismissFullScreenImage(sender: UITapGestureRecognizer) {
    print(sender.view)
    sender.view?.removeFromSuperview()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
