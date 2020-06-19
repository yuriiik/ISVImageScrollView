//
//  ISVImageScrollView.swift
//  ISVImageScrollView_Example
//
//  Created by Yurii Kupratsevych on 17.06.2020.
//  Copyright © 2020 kupratsevich@gmail.com. All rights reserved.
//

import UIKit

public class ISVImageScrollView: UIScrollView, UIGestureRecognizerDelegate {
  
  // MARK: - Public
  
  public var imageView: UIImageView? {
    didSet {
      oldValue?.removeGestureRecognizer(self.tap)
      oldValue?.removeFromSuperview()
      if let imageView = self.imageView {
        self.initialImageFrame = .null
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(self.tap)
        self.addSubview(imageView)
      }
    }
  }
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.configure()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.configure()
  }
  
  deinit {
    self.stopObservingBoundsChange()
  }
  
  // MARK: - UIScrollView
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.setupInitialImageFrame()
  }
  
  public override var contentOffset: CGPoint {
    didSet {
      let contentSize = self.contentSize
      let scrollViewSize = self.bounds.size
      var newContentOffset = contentOffset
      
      if contentSize.width < scrollViewSize.width {
        newContentOffset.x = (contentSize.width - scrollViewSize.width) * 0.5
      }
      
      if contentSize.height < scrollViewSize.height {
        newContentOffset.y = (contentSize.height - scrollViewSize.height) * 0.5
      }
      
      super.contentOffset = newContentOffset
    }
  }
  
  // MARK: - UIGestureRecognizerDelegate
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return otherGestureRecognizer === self.panGestureRecognizer
  }
  
  // MARK: - Private: Tap to Zoom
  
  private lazy var tap: UITapGestureRecognizer = {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapToZoom(_:)))
    tap.numberOfTapsRequired = 2
    tap.delegate = self
    return tap
  }()
  
  @IBAction private func tapToZoom(_ sender: UIGestureRecognizer) {
    guard sender.state == .ended else { return }
    if self.zoomScale > self.minimumZoomScale {
      self.setZoomScale(self.minimumZoomScale, animated: true)
    } else {
      guard let imageView = self.imageView else { return }
      let tapLocation = sender.location(in: imageView)
      let zoomRectWidth = imageView.frame.size.width / self.maximumZoomScale;
      let zoomRectHeight = imageView.frame.size.height / self.maximumZoomScale;
      let zoomRectX = tapLocation.x - zoomRectWidth * 0.5;
      let zoomRectY = tapLocation.y - zoomRectHeight * 0.5;
      let zoomRect = CGRect(
        x: zoomRectX,
        y: zoomRectY,
        width: zoomRectWidth,
        height: zoomRectHeight)
      self.zoom(to: zoomRect, animated: true)
    }
  }

  // MARK: - Private: Geometry
  
  private var initialImageFrame: CGRect = .null
  
  private var imageAspectRatio: CGFloat {
    guard let image = self.imageView?.image else { return 1 }
    return image.size.width / image.size.height
  }
  
  private func configure() {
    self.showsVerticalScrollIndicator = false
    self.showsHorizontalScrollIndicator = false
    self.startObservingBoundsChange()
  }
  
  private func rectSize(for aspectRatio: CGFloat, thatFits size: CGSize) -> CGSize {
    let containerWidth = size.width
    let containerHeight = size.height
    var resultWidth: CGFloat = 0
    var resultHeight: CGFloat = 0
    
    if aspectRatio <= 0 || containerHeight <= 0 {
      return size
    }
    
    if containerWidth / containerHeight >= aspectRatio {
      resultHeight = containerHeight
      resultWidth = containerHeight * aspectRatio
    } else {
      resultWidth = containerWidth
      resultHeight = containerWidth / aspectRatio
    }
    
    return CGSize(width: resultWidth, height: resultHeight)
  }
  
  private func scaleImageForTransition(from oldBounds: CGRect, to newBounds: CGRect) {
    guard let imageView = self.imageView else { return}
    
    let oldContentOffset = CGPoint(x: oldBounds.origin.x, y: oldBounds.origin.y)
    let oldSize = oldBounds.size
    let newSize = newBounds.size
    var containedImageSizeOld = self.rectSize(for: self.imageAspectRatio, thatFits: oldSize)
    let containedImageSizeNew = self.rectSize(for: self.imageAspectRatio, thatFits: newSize)
    
    if containedImageSizeOld.height <= 0 {
      containedImageSizeOld = containedImageSizeNew
    }
    
    let orientationRatio = containedImageSizeNew.height / containedImageSizeOld.height
    let transform = CGAffineTransform(scaleX: orientationRatio, y: orientationRatio)
    self.imageView?.frame = imageView.frame.applying(transform)
    self.contentSize = imageView.frame.size;
    
    var xOffset = (oldContentOffset.x + oldSize.width * 0.5) * orientationRatio - newSize.width * 0.5
    var yOffset = (oldContentOffset.y + oldSize.height * 0.5) * orientationRatio - newSize.height * 0.5
    
    xOffset -= max(xOffset + newSize.width - self.contentSize.width, 0)
    yOffset -= max(yOffset + newSize.height - self.contentSize.height, 0)
    xOffset -= min(xOffset, 0)
    yOffset -= min(yOffset, 0)
    
    self.contentOffset = CGPoint(x: xOffset, y: yOffset)
  }
  
  private func setupInitialImageFrame() {
    guard self.imageView != nil, self.initialImageFrame == .null else { return }
    let imageViewSize = self.rectSize(for: self.imageAspectRatio, thatFits: self.bounds.size)
    self.initialImageFrame = CGRect(x: 0, y: 0, width: imageViewSize.width, height: imageViewSize.height)
    self.imageView?.frame = self.initialImageFrame
    self.contentSize = self.initialImageFrame.size
  }
  
  // MARK: - Private: KVO
  
  private var boundsObserver: NSKeyValueObservation?
  
  private func startObservingBoundsChange() {
    self.boundsObserver = self.observe(
      \.self.bounds,
      options: [.old, .new],
      changeHandler: { [weak self] (object, change) in
        if let oldRect = change.oldValue,
          let newRect = change.newValue,
          oldRect.size != newRect.size {
          self?.scaleImageForTransition(from: oldRect, to: newRect)
        }
    })
  }
  
  private func stopObservingBoundsChange() {
    self.boundsObserver?.invalidate()
    self.boundsObserver = nil
  }
}
