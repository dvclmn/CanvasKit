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

  //  let canvasGeometry: CanvasGeometry
  let canvasSize: Size<CanvasSpace>

  /// Comes from `overlayPreferenceValue()` in `CanvasCoreView`
  let artworkFrameInViewport: CGRect
  let zoom: CGFloat
  let zoomRange: ClosedRange<CGFloat>
  //  let transformState: TransformState

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

  public func canvasPoint(
    fromViewportPoint point: CGPoint,
//    artworkFrameInViewport: CGRect
  ) -> CGPoint? {
    map(
      viewportPoint: point,
//      artworkFrameInViewport: artworkFrameInViewport
    ).canvas
    //    mapper?.map(viewportPoint: point, zoom: zoomClamped).canvas
  }

  /// This is the foundational mapping
  /// Provides a result that was similar to previous `pointerHoverMappedNative`
  ///
  //  public func map(viewportPoint point: CGPoint) -> HoverMapping? {
  //    mapper?.map(viewportPoint: point, zoom: zoomClamped)
  //  }

  public func map(
    viewportPoint: CGPoint,
//    artworkFrameInViewport: CGRect
      //    zoom: CGFloat
  ) -> HoverMapping {
    //    guard let artworkFrameInViewport else { return nil }
    let canvas = Point<CanvasSpace>(
      x: (viewportPoint.x - artworkFrameInViewport.minX) / zoomClamped,
      y: (viewportPoint.y - artworkFrameInViewport.minY) / zoomClamped
    )
    let isInside = isInsideCanvas(canvas)

    return HoverMapping(
      screen: viewportPoint,
      canvas: canvas.cgPoint,
      isInsideCanvas: isInside
    )
  }

  //  private var mapper: PointerHoverMapper? {
  //    guard let artworkFrameInViewport, let canvasSize else {
  //      return nil
  //    }
  //    return PointerHoverMapper(
  //      artworkFrameInViewport: artworkFrameInViewport,
  //      canvasSize: canvasSize,
  //      zoom: zoomClamped
  //    )
  //  }

  private var zoomSafe: CGFloat { zoom.isFinite && zoom > 0 ? zoom : 1 }
  private var zoomClamped: CGFloat { zoomSafe.clamped(to: zoomRange) }
}

// MARK: - Containment check
extension PointerHandler {
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
//  public var context: ViewportContext
//
//  public init(context: ViewportContext) {
//    self.context = context
//  }
//}

//extension PointerHoverHandler {
//  public var canvasRect: CGRect {
//    CGRect(origin: .zero, size: context.canvasSize.cgSize)
//  }
//
//  private var canvasXRange: Range<CGFloat> { 0..<context.canvasSize.width }
//  private var canvasYRange: Range<CGFloat> { 0..<context.canvasSize.height }
//
//  public func isInsideCanvas(_ canvasPoint: Point<CanvasSpace>) -> Bool {
//    canvasXRange.contains(canvasPoint.x)
//      && canvasYRange.contains(canvasPoint.y)
//  }
//
//  public func isInsideCanvas(_ canvasPoint: CGPoint) -> Bool {
//    isInsideCanvas(Point<CanvasSpace>(fromPoint: canvasPoint))
//  }
//
//  public func map(screenPoint: Point<ScreenSpace>) -> HoverMapping {
//    let canvas = context.toCanvas(screenPoint: screenPoint)
//    let isInside = isInsideCanvas(canvas)
//
//    return HoverMapping(
//      screen: screenPoint,
//      canvas: canvas,
//      isInsideCanvas: isInside
//    )
//  }
//
//  public func map(screenPoint: CGPoint) -> HoverMapping {
//    map(screenPoint: Point<ScreenSpace>(fromPoint: screenPoint))
//  }
//
//  public func mapIfInside(
//    screenPoint: Point<ScreenSpace>
//  ) -> HoverMapping? {
//    let mapped = map(screenPoint: screenPoint)
//    return mapped.isInsideCanvas ? mapped : nil
//  }
//
//  public func mapIfInside(
//    screenPoint: CGPoint
//  ) -> HoverMapping? {
//    mapIfInside(screenPoint: Point<ScreenSpace>(fromPoint: screenPoint))
//  }
//
//  #if DEBUG
//  public func roundTripError(screenPoint: CGPoint) -> CGFloat {
//    let mapped = map(screenPoint: screenPoint)
//    let roundTrip = context.toGlobal(point: mapped.canvasPoint.cgPoint)
//    return hypot(
//      roundTrip.x - screenPoint.x,
//      roundTrip.y - screenPoint.y
//    )
//  }
//  #endif
//}
