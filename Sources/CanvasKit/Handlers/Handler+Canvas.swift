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
  
  private func mappedPointerLocation() -> CGPoint? {
    pointerMapper(zoom: zoom)?.canvasPoint(fromViewportPoint: location)
  }

  func handleTap(
    at location: CGPoint,
    zoom: Double,
    state: inout CanvasInteractionState
  ) {
    let mapped = pointerMapper(zoom: zoom)?.canvasPoint(fromViewportPoint: location)
    state.pointer.tap.update(mapped, phase: .ended)
  }
  
  func handleHover(
    _ phase: HoverPhase,
    zoom: Double,
  ) {
    let mapped =
//    let mapped = store.mappedHoverLocation(phase, zoom: zoom)
    interactionState.pointer.hover.update(mapped, phase: InteractionPhase(fromHover: phase))
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
      resolver: zoomFocusResolver,
      zoomRange: zoomRange
    )
    return handler.updateZoom(state: &state)
  }

}

// MARK: - Zoom {
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

  @discardableResult
  public func updateHover(
    using event: ZoomGestureEvent,
    interactionState: inout CanvasInteractionState,
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
