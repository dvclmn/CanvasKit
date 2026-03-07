//
//  PointZoom.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/10/2025.
//

import BasePrimitives
import Foundation

extension CGPoint {
  public func removingZoom(_ zoom: CGFloat) -> CGPoint {
    return self / zoom
  }

  func removingZoomPercent(_ zoomPercent: CGFloat) -> CGPoint {
    let adjustedX = self.x.removingZoomPercent(zoomPercent)
    let adjustedY = self.y.removingZoomPercent(zoomPercent)
    return CGPoint(x: adjustedX, y: adjustedY)
  }

  public func removingPanAndZoom(pan: CGSize, zoom: CGFloat) -> CGPoint {
    let unPanned: CGPoint = self - pan
    let unZoomed: CGPoint = unPanned / zoom
    return unZoomed
  }
  public func applyPanAndZoom(pan: CGSize, zoom: CGFloat) -> CGPoint {
    let scaled = CGPoint(
      x: x * zoom,
      y: y * zoom
    )
    let translated = CGPoint(
      x: scaled.x + pan.width,
      y: scaled.y + pan.height
    )
    return translated
  }
}

extension CGSize {
  public func addingZoom(_ zoom: CGFloat) -> CGSize {
    return self * zoom
  }

  public func removingZoom(_ zoom: CGFloat) -> CGSize {
    return self / zoom
  }

  func removingZoomPercent(_ zoomPercent: CGFloat) -> CGSize {
    let adjustedWidth = self.width.removingZoomPercent(zoomPercent)
    let adjustedHeight = self.height.removingZoomPercent(zoomPercent)
    return CGSize(width: adjustedWidth, height: adjustedHeight)
  }
}
