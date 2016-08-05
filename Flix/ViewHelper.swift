//
//  ViewHelper.swift
//  Flix
//
//  Created by kate_odnous on 8/4/16.
//  Copyright © 2016 Kate Odnous. All rights reserved.
//

import UIKit

class ViewHelper {
  static func loadAndFadeInImage(imageView: UIImageView, imageURL: String) {
    let request = NSURLRequest(URL: NSURL(string: imageURL)!)
    
    imageView.setImageWithURLRequest(
      request,
      placeholderImage: nil,
      success: { (request, imageResponse, image) -> Void in
        // imageResponse will be nil if the image is cached
        if imageResponse != nil {
          imageView.alpha = 0.0
          imageView.image = image
          UIView.animateWithDuration(0.3, animations: { () -> Void in
            imageView.alpha = 1.0
          })
        } else {
          imageView.image = image
        }
      },
      failure: {(imageRequest, imageResponse, error) -> Void in
        print("failed to load image")
      }
    )
  }
}