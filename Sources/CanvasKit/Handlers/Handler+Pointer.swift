//
//  Handler+Pointer.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/1/2026.
//

import BasePrimitives
import Foundation
import GestureKit

/// I think pointer handler doesn't need CanvasViewportMapping?
struct PointerHandler {

  let canvasSize: Size<CanvasSpace>

  /// The artwork bounds resolved in the viewport named coordinate space.
  /// Captured via SwiftUI anchor preferences in `CanvasCoreView`.
  let canvasFrameInViewport: Rect<CanvasSpace>
  //  let canvasFrameInViewport: CGRect
  let zoom: CGFloat
  let zoomRange: ClosedRange<CGFloat>

  init?(
    canvasSize: Size<CanvasSpace>?,
    canvasFrameInViewport: Rect<CanvasSpace>?,
    zoom: CGFloat,
    zoomRange: ClosedRange<CGFloat>?
  ) {
    guard let canvasSize,
      let canvasFrameInViewport,
      let zoomRange
    else { return nil }
    self.canvasSize = canvasSize
    self.canvasFrameInViewport = canvasFrameInViewport
    self.zoom = zoom
    self.zoomRange = zoomRange
  }
}

extension PointerHandler {

  public func canvasPoint(
    fromViewportPoint point: CGPoint
  ) -> Point<CanvasSpace>? {
    Point<CanvasSpace>(
      //    let canvas = Point<CanvasSpace>(
      x: (point.x - canvasFrameInViewport.minX) / zoomClamped,
      y: (point.y - canvasFrameInViewport.minY) / zoomClamped
    )
    //          return HoverMapping(
    //            screen: viewportPoint,
    //            canvas: canvas.cgPoint,
    //            isInsideCanvas: isInsideCanvas(canvas)
    //          )
    //    map(viewportPoint: point).canvas
  }

  //  public func map(viewportPoint: CGPoint) -> HoverMapping {
  //    let canvas = Point<CanvasSpace>(
  //      x: (viewportPoint.x - canvasFrameInViewport.minX) / zoomClamped,
  //      y: (viewportPoint.y - canvasFrameInViewport.minY) / zoomClamped
  //    )
  //    return HoverMapping(
  //      screen: viewportPoint,
  //      canvas: canvas.cgPoint,
  //      isInsideCanvas: isInsideCanvas(canvas)
  //    )
  //  }

  private var zoomSafe: CGFloat { zoom.isFinite && zoom > 0 ? zoom : 1 }
  private var zoomClamped: CGFloat { zoomSafe.clamped(to: zoomRange) }
}

// MARK: - Containment check
extension PointerHandler {

  private var canvasXRange: Range<CGFloat> { 0..<canvasSize.width }
  private var canvasYRange: Range<CGFloat> { 0..<canvasSize.height }

  public func isInsideCanvas(_ canvasPoint: Point<CanvasSpace>) -> Bool {
    canvasXRange.contains(canvasPoint.x)
      && canvasYRange.contains(canvasPoint.y)
  }

  public func isInsideCanvas(_ canvasPoint: CGPoint) -> Bool {
    isInsideCanvas(Point<CanvasSpace>(fromPoint: canvasPoint))
  }
}
