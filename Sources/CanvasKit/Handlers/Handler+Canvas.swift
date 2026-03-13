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
  //  var zoomFocusResolver: ZoomFocusResolver = .viewportCentre

  public init() {}
}

extension CanvasHandler {

  func handleTap(
    at location: CGPoint,
    zoom: Double,
    state: inout CanvasInteractionState
  ) {
    let mapped = mappedPointer(location, zoom: zoom)

    //    let mapped = pointerMapper(zoom: zoom)?.canvasPoint(fromViewportPoint: location)
    state.pointer.tap.update(mapped, phase: .ended)
  }

  func handleHover(
    _ phase: HoverPhase,
    zoom: Double,
    state: inout CanvasInteractionState
  ) {
    guard let location = phase.location else { return }
    let mapped = mappedPointer(location, zoom: zoom)
    state.pointer.hover.update(mapped, phase: phase.interactionPhase)
  }

  func handleZoom(
    _ zoomEvent: ZoomGestureEvent,
    geometry: CanvasGeometry?,
    state: inout CanvasInteractionState
  ) -> Double {
    guard let geometry else {
      let newZoom = zoomEvent.magnification
      state.transform.zoom.update(newZoom, phase: zoomEvent.phase)
      return newZoom
    }
    let handler = ZoomHandler(
      zoomEvent: zoomEvent,
      geometry: geometry,
      //      resolver: zoomFocusResolver,
      zoomRange: zoomRange
    )
    return handler.updateZoom(state: &state)
  }

}

// MARK: - Zoom {
extension CanvasHandler {

  private func mappedPointer(
    _ location: CGPoint,
    zoom: Double
  ) -> CGPoint? {
    guard let zoomRange else { return nil }
    return PointerHandler(
      canvasSize: canvasSize,
      artworkFrameInViewport: canvasFrameInViewport,
      zoom: zoom,
      zoomRange: zoomRange.toCGFloatRange
    )?.canvasPoint(fromViewportPoint: location)
    //    pointerMapper(zoom: zoom)?.canvasPoint(fromViewportPoint: location)
  }

  //  private func pointerMapper(
  //    zoom: CGFloat?
  //  ) -> PointerHandler? {
  //    guard let zoomRange, let zoom else { return nil }
  //    return .init(
  //      canvasSize: canvasSize,
  //      artworkFrameInViewport: canvasFrameInViewport,
  //      zoom: zoom,
  //      zoomRange: zoomRange.toCGFloatRange
  //    )
  //  }

  //  @discardableResult
  //  public func updateHover(
  //    using event: ZoomGestureEvent,
  //    interactionState: inout CanvasInteractionState,
  //    geometry: CanvasGeometry,
  //    in zoomRange: ClosedRange<Double>?
  //  ) -> Double {
  //    ZoomHandler(
  //      zoomEvent: event,
  //      geometry: geometry,
  //      //      resolver: zoomFocusResolver,
  //      zoomRange: zoomRange
  //    )
  //    .updateZoom(state: &interactionState)
  //  }

  /// Updates zoom while preserving the focused screen point.
  /// This makes pinch/spread feel anchored to pointer intent instead of viewport centre.
  //  @discardableResult
  //  public func updateZoom(
  //    using event: ZoomGestureEvent,
  //    interactionState: inout CanvasInteractionState,
  //    geometry: CanvasGeometry,
  //    in zoomRange: ClosedRange<Double>?
  //  ) -> Double {
  //    ZoomHandler(
  //      zoomEvent: event,
  //      geometry: geometry,
  //      resolver: zoomFocusResolver,
  //      zoomRange: zoomRange
  //    ).updateZoom(interactionState: &interactionState)
  //  }
}
