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
  var canvasFrameInViewport: Rect<CanvasSpace>?
  //  var canvasFrameInViewport: CGRect?
  var canvasSize: Size<CanvasSpace>?

  /// Zoom multiplier per click when using the Zoom tool tap.
  /// Default 0.25 means each click zooms by 25% (1.0 → 1.25 → 1.5625…).
  /// Consumers can adjust this to taste.
  public var zoomStepFactor: Double = 0.25

  /// Sensitivity for pointer-drag zoom (zoom delta per pixel of vertical drag).
  /// Positive values mean drag-up = zoom in.
  public var pointerZoomSensitivity: Double = 0.005

  public init() {}
}

extension CanvasHandler {

  func handlePan(
    delta: CGSize,
    phase: InteractionPhase,
    state: inout CanvasInteractionState,
    source: InteractionSource
  ) {
    state.transform.pan.updateDelta(
      delta,
      phase: phase,
      source: source
    )
  }
  func handleTap(
    at location: CGPoint,
    zoom: Double,
    state: inout CanvasInteractionState
  ) {
    let mapped = pointerCanvasLocation(from: location, zoom: zoom)?.cgPoint
    state.pointer.tap.update(
      mapped,
      phase: .ended,
      source: .
    )
  }

  func handleHover(
    _ phase: HoverPhase,
    zoom: Double,
    state: inout CanvasInteractionState
  ) {
    guard let location = phase.location else { return }
    let mapped = pointerCanvasLocation(from: location, zoom: zoom)?.cgPoint
    state.pointer.hover.update(mapped, phase: phase.interactionPhase)
  }

  func handleZoom(
    _ zoomEvent: ZoomGestureEvent,
    geometry: CanvasGeometry?,
    state: inout CanvasInteractionState
  ) -> Double {
    guard let geometry else {
      let newZoom = zoomEvent.magnification
      state.transform.zoom.update(
        newZoom,
        phase: zoomEvent.phase,
        source: .
      )
      return newZoom
    }
    let handler = ZoomHandler(
      zoomEvent: zoomEvent,
      geometry: geometry,
      zoomRange: zoomRange
    )
    return handler.updateZoom(state: &state)
  }

  /// Applies a step zoom at the given location (Zoom tool click).
  ///
  /// - Parameters:
  ///   - location: Viewport-space tap location.
  ///   - zoomIn: `true` to zoom in, `false` to zoom out (Option key).
  ///   - geometry: Current canvas geometry for focus-preserving zoom.
  ///   - state: Interaction state to mutate.
  func handleStepZoom(
    at location: CGPoint,
    zoomIn: Bool,
    geometry: CanvasGeometry?,
    state: inout CanvasInteractionState
  ) {
    let currentZoom = state.zoom
    let factor = zoomIn ? (1.0 + zoomStepFactor) : (1.0 / (1.0 + zoomStepFactor))
    let proposedZoom = currentZoom * factor

    let event = ZoomGestureEvent(
      phase: .ended,
      previousZoom: currentZoom,
      proposedZoom: proposedZoom,
      magnification: proposedZoom,
      magnificationDelta: proposedZoom - currentZoom,
      isGestureStart: true
    )

    /// Latch the focus point so zoom centers on the click location.
    state.pointer.hover.update(location, phase: .changed)
    _ = handleZoom(event, geometry: geometry, state: &state)
  }

  /// Applies continuous zoom from a pointer drag delta (Zoom tool drag).
  ///
  /// Vertical drag: up = zoom in, down = zoom out.
  /// The `invertDirection` flag (Option key) reverses this.
  func handlePointerZoom(
    verticalDelta: CGFloat,
    invertDirection: Bool,
    geometry: CanvasGeometry?,
    state: inout CanvasInteractionState
  ) {
    let currentZoom = state.zoom
    // Negative delta = dragged up in screen coords = zoom in.
    let direction: Double = invertDirection ? 1.0 : -1.0
    let zoomDelta = Double(verticalDelta) * pointerZoomSensitivity * direction
    let proposedZoom = currentZoom * (1.0 + zoomDelta)

    let event = ZoomGestureEvent(
      phase: .changed,
      previousZoom: currentZoom,
      proposedZoom: proposedZoom,
      magnification: proposedZoom,
      magnificationDelta: proposedZoom - currentZoom,
      isGestureStart: false
    )

    _ = handleZoom(event, geometry: geometry, state: &state)
  }

}

// MARK: - Coordinate Mapping
extension CanvasHandler {

  private func pointerCanvasLocation(
    //    from screenLocation: Point<ScreenSpace>,
    from screenLocation: CGPoint,
    zoom: Double
  ) -> Point<CanvasSpace>? {
    //  ) -> CGPoint? {
    guard let zoomRange else { return nil }
    return PointerHandler(
      canvasSize: canvasSize,
      canvasFrameInViewport: canvasFrameInViewport,
      zoom: zoom,
      zoomRange: zoomRange.toCGFloatRange
    )?.canvasPoint(fromViewportPoint: screenLocation)
  }

}
