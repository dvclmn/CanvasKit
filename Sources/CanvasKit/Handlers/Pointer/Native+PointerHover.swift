//
//  Native+PointerHover.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 6/3/2026.
//

import BasePrimitives
import Foundation

public struct NativePointerHoverHandler {
  public var artworkFrameInViewport: CGRect
  public var canvasSize: Size<CanvasSpace>
  public var zoom: CGFloat

  public init(
    artworkFrameInViewport: CGRect,
    canvasSize: Size<CanvasSpace>,
    zoom: CGFloat
  ) {
    self.artworkFrameInViewport = artworkFrameInViewport
    self.canvasSize = canvasSize
    self.zoom = zoom
  }
}

extension NativePointerHoverHandler {
  //  public var canvasRect: CGRect {
  //    CGRect(origin: .zero, size: canvasSize.cgSize)
  //  }

  private var zoomSafe: CGFloat { zoom.isFinite && zoom > 0 ? zoom : 1 }


  public func map(viewportPoint: CGPoint) -> HoverMapping {
    let canvas = Point<CanvasSpace>(
      x: (viewportPoint.x - artworkFrameInViewport.minX) / zoomSafe,
      y: (viewportPoint.y - artworkFrameInViewport.minY) / zoomSafe
    )
    let isInside = isInsideCanvas(canvas)

    return HoverMapping(
      screen: viewportPoint,
      canvas: canvas.cgPoint,
      isInsideCanvas: isInside
    )
  }

//  public func mapIfInside(viewportPoint: CGPoint) -> HoverMapping? {
//    let mapped = map(viewportPoint: viewportPoint)
//    return mapped.isInsideCanvas ? mapped : nil
//  }


}

// MARK: - Containment check

extension NativePointerHoverHandler {
  private var canvasXRange: Range<CGFloat> {
    0..<canvasSize.width
  }
  
  private var canvasYRange: Range<CGFloat> {
    0..<canvasSize.height
  }
  
  public func isInsideCanvas(_ canvasPoint: Point<CanvasSpace>) -> Bool {
    canvasXRange.contains(canvasPoint.x)
    && canvasYRange.contains(canvasPoint.y)
  }
  
  public func isInsideCanvas(_ canvasPoint: CGPoint) -> Bool {
    isInsideCanvas(Point<CanvasSpace>(fromPoint: canvasPoint))
  }

}

// MARK: - Debug
extension NativePointerHoverHandler {
#if DEBUG
  public func roundTripError(viewportPoint: CGPoint) -> CGFloat {
    let mapped = map(viewportPoint: viewportPoint)
    let roundTrip = CGPoint(
      x: (mapped.canvas.x * zoomSafe) + artworkFrameInViewport.minX,
      y: (mapped.canvas.y * zoomSafe) + artworkFrameInViewport.minY
    )
    return hypot(
      roundTrip.x - viewportPoint.x,
      roundTrip.y - viewportPoint.y
    )
  }
#endif
}
