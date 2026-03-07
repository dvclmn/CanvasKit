//
//  Handler+Pointer.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/1/2026.
//

import BasePrimitives
import Foundation
import GestureKit

/// I think pointer handler doesn't need ViewportContext?
struct PointerHandler {

  let canvasSize: Size<CanvasSpace>

  /// Comes from `overlayPreferenceValue()` in `CanvasCoreView`
  let artworkFrameInViewport: CGRect
  let zoom: CGFloat
  let zoomRange: ClosedRange<CGFloat>

  init?(
    canvasSize: Size<CanvasSpace>?,
    artworkFrameInViewport: CGRect?,
    zoom: CGFloat,
    zoomRange: ClosedRange<CGFloat>?
  ) {
    guard let canvasSize,
      let artworkFrameInViewport,
      let zoomRange
    else { return nil }
    self.canvasSize = canvasSize
    self.artworkFrameInViewport = artworkFrameInViewport
    self.zoom = zoom
    self.zoomRange = zoomRange
  }
}

extension PointerHandler {

  public func canvasPoint(fromViewportPoint point: CGPoint) -> CGPoint? {
    map(viewportPoint: point).canvas
  }

  public func map(viewportPoint: CGPoint) -> HoverMapping {
    let canvas = Point<CanvasSpace>(
      x: (viewportPoint.x - artworkFrameInViewport.minX) / zoomClamped,
      y: (viewportPoint.y - artworkFrameInViewport.minY) / zoomClamped
    )
    return HoverMapping(
      screen: viewportPoint,
      canvas: canvas.cgPoint,
      isInsideCanvas: isInsideCanvas(canvas)
    )
  }

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
