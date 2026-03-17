//
//  Handler+Pointer.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/1/2026.
//

import BasePrimitives
import Foundation

struct CoordinateSpaceMapper {
  let geometry: CanvasGeometry
  let transform: TransformState
  let zoomRange: ClosedRange<Double>?
}

extension CoordinateSpaceMapper {
  private var canvasFrameInViewport: Rect<CanvasSpace> { geometry.canvasFrameInViewport }
  private var zoomClamped: CGFloat {
    guard transform.scale.isFiniteAndGreaterThanZero else { return 1 }
    return transform.scale.clampedIfNeeded(to: zoomRange)
  }

  /// Convert screen-space point to canvas-space
  func canvasPoint(from screenPoint: Point<ScreenSpace>) -> Point<CanvasSpace> {
    //    let x = (screenPoint.x - canvasFrameInViewport.minX) / zoomClamped
    //    let y = (screenPoint.y - canvasFrameInViewport.minY) / zoomClamped

    Point<CanvasSpace>(
      //      x: max(0, x),
      //      y: max(0, y)
      x: (screenPoint.x - canvasFrameInViewport.minX) / zoomClamped,
      y: (screenPoint.y - canvasFrameInViewport.minY) / zoomClamped
    )
  }

  /// Convert canvas-space point to screen-space
  func screenPoint(from canvasPoint: Point<CanvasSpace>) -> Point<ScreenSpace> {
    fatalError("Not yet implemented")
  }

  private var canvasXRange: Range<CGFloat> { 0..<canvasSize.width }
  private var canvasYRange: Range<CGFloat> { 0..<canvasSize.height }

  public func isInsideCanvas(_ canvasPoint: Point<CanvasSpace>) -> Bool {
    canvasXRange.contains(canvasPoint.x)
      && canvasYRange.contains(canvasPoint.y)
  }
}

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
//  let canvasFrameInViewport: Rect<CanvasSpace>
//
//  let zoom: CGFloat
//
//  /// Expects that zoom comes in already clamped within safe bounds
//  init?(
//    canvasSize: Size<CanvasSpace>?,
//    canvasFrameInViewport: Rect<CanvasSpace>?,
//    zoomClamped: CGFloat?
//  ) {
//    guard let canvasSize,
//      let canvasFrameInViewport,
//      let zoomClamped
//    else { return nil }
//    self.canvasSize = canvasSize
//    self.canvasFrameInViewport = canvasFrameInViewport
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
//      x: (point.x - canvasFrameInViewport.minX) / zoom,
//      y: (point.y - canvasFrameInViewport.minY) / zoom
//    )
//  }
//}

// MARK: - Containment check
//extension PointerHandler {
//
//
//}
