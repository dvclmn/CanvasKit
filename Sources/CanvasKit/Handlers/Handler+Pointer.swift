//
//  Handler+Pointer.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/1/2026.
//

import CoreTools
import Foundation
import GestureKit

public struct PointerHoverHandler {
  public var context: ViewportContext

  public init(context: ViewportContext) {
    self.context = context
  }
}

extension PointerHoverHandler {
  public var canvasRect: CGRect {
    CGRect(origin: .zero, size: context.canvasSize.cgSize)
  }

  private var canvasXRange: Range<CGFloat> {
    0..<context.canvasSize.width
  }

  private var canvasYRange: Range<CGFloat> {
    0..<context.canvasSize.height
  }

  public func isInsideCanvas(_ canvasPoint: Point<CanvasSpace>) -> Bool {
    canvasXRange.contains(canvasPoint.x)
      && canvasYRange.contains(canvasPoint.y)
  }

  public func isInsideCanvas(_ canvasPoint: CGPoint) -> Bool {
    isInsideCanvas(Point<CanvasSpace>(fromPoint: canvasPoint))
  }

  public func map(screenPoint: Point<ScreenSpace>) -> HoverMapping {
    let canvas = context.toCanvas(screenPoint: screenPoint)
    let isInside = isInsideCanvas(canvas)

    return HoverMapping(
      screen: screenPoint,
      canvas: canvas,
      isInsideCanvas: isInside
    )
  }

  public func map(screenPoint: CGPoint) -> HoverMapping {
    map(screenPoint: Point<ScreenSpace>(fromPoint: screenPoint))
  }

  public func mapIfInside(
    screenPoint: Point<ScreenSpace>
  ) -> HoverMapping? {
    let mapped = map(screenPoint: screenPoint)
    return mapped.isInsideCanvas ? mapped : nil
  }

  public func mapIfInside(
    screenPoint: CGPoint
  ) -> HoverMapping? {
    mapIfInside(screenPoint: Point<ScreenSpace>(fromPoint: screenPoint))
  }
 
  #if DEBUG
  public func roundTripError(screenPoint: CGPoint) -> CGFloat {
    let mapped = map(screenPoint: screenPoint)
    let roundTrip = context.toGlobal(point: mapped.canvasPoint.cgPoint)
    return hypot(
      roundTrip.x - screenPoint.x,
      roundTrip.y - screenPoint.y
    )
  }
  #endif
}

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
  public var canvasRect: CGRect {
    CGRect(origin: .zero, size: canvasSize.cgSize)
  }

  private var zoomSafe: CGFloat {
    if zoom.isFinite, zoom > 0 {
      return zoom
    }
    return 1
  }

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

  public func mapIfInside(viewportPoint: CGPoint) -> HoverMapping? {
    let mapped = map(viewportPoint: viewportPoint)
    return mapped.isInsideCanvas ? mapped : nil
  }

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
