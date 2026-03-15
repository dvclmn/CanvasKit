//
//  Handler+Zoom.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 7/3/2026.
//

import BasePrimitives
import Foundation

struct ZoomHandler {
  let zoomEvent: ZoomGestureEvent
  let geometry: CanvasGeometry
  //  let resolver: ZoomFocusResolver
  let zoomRange: ClosedRange<Double>?
}

// MARK: - Main update

extension ZoomHandler {

  @discardableResult
  func updateZoom(state: inout CanvasInteractionState) -> Double {
    defer {
      clearLatchedZoomFocusIfNeeded(
        for: zoomEvent.phase,
        interactionState: &state
      )
    }

    let currentZoom = state.zoom

    let previousZoom = clampedProposedZoom(zoomEvent.previousZoom, currentZoom: currentZoom)
    let nextZoom = clampedProposedZoom(zoomEvent.proposedZoom, currentZoom: currentZoom)

    state.transform.zoom.update(nextZoom, phase: zoomEvent.phase)

    guard isZoomSafe(prev: previousZoom, next: nextZoom)
    //      let resolved = resolver.resolved(
    //        for: zoomEvent.phase,
    //        pointerLocation: state.pointer.hover.value,
    //        transform: &state.transform,
    //        geometry: geometry
    //      )
    else { return currentZoom }

    let resolved = state.pointer.hover.value ?? geometry.viewportRect.midpoint

    let focus = sanitisedFocusPoint(resolved)

    guard
      let previousContext = geometry.viewportMapping(
        zoom: CGFloat(previousZoom),
        pan: state.transform.pan.value
      )
    else { return currentZoom }

    let focusCanvas = previousContext.toCanvas(
      screenPoint: focus
    )

    guard
      let newContextZeroPan = geometry.viewportMapping(
        zoom: CGFloat(nextZoom),
        pan: .zero
      )
    else { return currentZoom }

    let focusGlobalAtZeroPan = newContextZeroPan.toGlobal(point: focusCanvas.cgPoint)

    let proposedPan = Size<ScreenSpace>(
//    let proposedPan = CGSize(
      width: focus.x - focusGlobalAtZeroPan.x,
      height: focus.y - focusGlobalAtZeroPan.y
    )

    state.transform.pan.value = clampedPan(
      proposedPan,
      at: nextZoom,
      state: state
    )
    return state.zoom
  }
}

// MARK: - Helpers

extension ZoomHandler {
  private func clearLatchedZoomFocusIfNeeded(
    for phase: InteractionPhase,
    interactionState: inout CanvasInteractionState
  ) {
    guard !phase.isActive else { return }
    interactionState.transform.latchedZoomFocusGlobal = nil
  }

  private func clampedProposedZoom(_ proposedZoom: Double, currentZoom: Double) -> Double {
    guard proposedZoom.isFinite else {
      return currentZoom.clampedIfNeeded(to: zoomRange)
    }
    return proposedZoom.clampedIfNeeded(to: zoomRange)
  }

  private func clampedPan(
    _ proposedPan: Size<ScreenSpace>,
    //    _ proposedPan: CGSize,
    at zoom: Double,
    state: CanvasInteractionState
  ) -> Size<ScreenSpace> {
//  ) -> CGSize {
    var candidate = state.transform.pan
    candidate.value = proposedPan
    return candidate.clamped(to: geometry, zoom: CGFloat(zoom))
  }

  private func sanitisedFocusPoint(_ point: Point<ScreenSpace>) -> Point<ScreenSpace> {
    //  private func sanitisedFocusPoint(_ point: CGPoint) -> CGPoint {
    let fallback = geometry.viewportRect.midpoint
    guard point.x.isFinite, point.y.isFinite else {
      return fallback
    }
    return point
  }

  private func isZoomSafe(prev previousZoom: Double, next nextZoom: Double) -> Bool {
    geometry.isValidForCoordinateMapping
      && previousZoom.isFinite && nextZoom.isFinite
      && previousZoom > 0 && nextZoom > 0
      && abs(nextZoom - previousZoom) > .ulpOfOne
  }
}
