//
//  Handler+CanvasGesture.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/6/2025.
//

import BasePrimitives
import GestureKit
import SwiftUI

@Observable
public final class CanvasHandler {
  var zoomRange: ClosedRange<Double>?

  var canvasFrameInViewport: CGRect?
  var canvasSize: Size<CanvasSpace>?

  var zoomFocusResolver: ZoomFocusResolver = .viewportCentre
  var activeDragType: DragBehavior = .none

  public init() {}
}

extension CanvasHandler {
  private func pointerMapper(
    zoom: CGFloat?
  ) -> PointerHandler? {
    guard let zoomRange, let zoom else { return nil }
    return .init(
      canvasSize: canvasSize,
      artworkFrameInViewport: canvasFrameInViewport,
      zoom: zoom,
      zoomRange: zoomRange.toCGFloatRange
    )
  }

  func mappedTapLocation(
    _ location: CGPoint,
    zoom: CGFloat?
  ) -> CGPoint? {
    pointerMapper(zoom: zoom)?.canvasPoint(fromViewportPoint: location)
  }

  func mappedHoverLocation(
    _ phase: HoverPhase,
    zoom: CGFloat?
  ) -> CGPoint? {
    guard
      let location =
        switch phase {
          case .active(let val): val
          case .ended: nil
        }
    else { return nil }
    return pointerMapper(zoom: zoom)?.canvasPoint(fromViewportPoint: location)
  }
}

// MARK: - Zoom {
extension CanvasHandler {

  /// Updates zoom while preserving the focused screen point.
  /// This makes pinch/spread feel anchored to pointer intent instead of viewport centre.
  @discardableResult
  public func updateZoom(
    using event: ZoomGestureEvent,
    interactionState: inout CanvasInteraction,
    geometry: CanvasGeometry,
    in zoomRange: ClosedRange<Double>?
  ) -> Double {
    ZoomHandler(
      zoomEvent: event,
      geometry: geometry,
      resolver: zoomFocusResolver,
      zoomRange: zoomRange
    ).updateZoom(interactionState: &interactionState)
  }
}
