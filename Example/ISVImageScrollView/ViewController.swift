//
//  ViewController.swift
//  ISVImageScrollView_Example
//
//  Created by Yurii Kupratsevych on 17.06.2020.
//  Copyright © 2020 kupratsevich@gmail.com. All rights reserved.
//

import UIKit
import ISVImageScrollView

class ViewController: UIViewController, UIScrollViewDelegate {
  
  @IBOutlet weak var imageScrollView: ISVImageScrollView!
  private var imageView: UIImageView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let image = UIImage(named: "Photo.jpg")
    self.imageView = UIImageView(image: image)
    self.imageScrollView.imageView = self.imageView
    self.imageScrollView.maximumZoomScale = 4.0
    self.imageScrollView.delegate = self
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }

  // MARK: - UIScrollViewDelegate
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return self.imageView
  }
}
