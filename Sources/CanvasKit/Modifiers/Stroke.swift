//
//  Stroke.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//

import SwiftUI

extension GraphicsContext {
  func unZoomedLineWidth(
    for width: CGFloat,
    sensitivity: CGFloat? = 0.2
  ) -> CGFloat {
    let range = environment.zoomRange
    //    guard let range = environment.zoomRange else {
    //      return width
    //    }
    return width.removingZoom(
      environment.zoomLevel,
      across: range.toCGFloatRange,
      sensitivity: sensitivity
    )
  }
}
