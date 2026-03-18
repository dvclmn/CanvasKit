//
//  Handler+Pointer.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/1/2026.
//

import BasePrimitives
import Foundation



//struct PointerMapping {
//  let geometry: CanvasGeometry
//}

/// I think pointer handler doesn't need CanvasViewportMapping?
//struct PointerHandler {
//
//  let canvasSize: Size<CanvasSpace>
//
//  /// The artwork bounds resolved in the viewport named coordinate space.
//  /// Captured via SwiftUI anchor preferences in `CanvasCoreView`.
//  let artworkFrameInViewport: Rect<CanvasSpace>
//
//  let zoom: CGFloat
//
//  /// Expects that zoom comes in already clamped within safe bounds
//  init?(
//    canvasSize: Size<CanvasSpace>?,
//    artworkFrameInViewport: Rect<CanvasSpace>?,
//    zoomClamped: CGFloat?
//  ) {
//    guard let canvasSize,
//      let artworkFrameInViewport,
//      let zoomClamped
//    else { return nil }
//    self.canvasSize = canvasSize
//    self.artworkFrameInViewport = artworkFrameInViewport
//    self.zoom = zoomClamped
//  }
//}

//extension PointerHandler {
//
//  public static func
//
//  public func canvasPoint(
//    fromViewportPoint point: CGPoint
//  ) -> Point<CanvasSpace>? {
//    Point<CanvasSpace>(
//      x: (point.x - artworkFrameInViewport.minX) / zoom,
//      y: (point.y - artworkFrameInViewport.minY) / zoom
//    )
//  }
//}

// MARK: - Containment check
//extension PointerHandler {
//
//
//}
