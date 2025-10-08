//
//  PointZoom.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/10/2025.
//

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
}
