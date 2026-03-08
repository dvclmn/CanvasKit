//
//  Canvas+FocusedZoom.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 1/3/2026.
//

import BasePrimitives
import GestureKit
import SwiftUI

extension CanvasHandler {

  /// Updates zoom while preserving the focused screen point.
  /// This makes pinch/spread feel anchored to pointer intent instead of viewport centre.
  @discardableResult
  public func updateZoom(
    using event: ZoomGestureEvent,
    interactionState: inout InteractionState,
    geometry: CanvasGeometry,
    in zoomRange: ClosedRange<Double>?
  ) -> Double {
    defer { clearLatchedZoomFocusIfNeeded(for: event.phase, interactionState: &interactionState) }

    let currentZoom = interactionState.transform.zoomState.zoom

    let previousZoom = clampedProposedZoom(event.previousZoom, currentZoom: currentZoom, in: zoomRange)
    let nextZoom = clampedProposedZoom(event.proposedZoom, currentZoom: currentZoom, in: zoomRange)

    interactionState.transform.zoomState.update(nextZoom, phase: event.phase)

    guard isZoomSafe(in: geometry, prev: previousZoom, next: nextZoom),
      let resolved = zoomFocusResolver.resolved(
        for: event.phase,
        pointerLocation: interactionState.pointer.pointerHover.value,
        transform: &interactionState.transform,
        geometry: geometry
      )
    else { return currentZoom }

    let focus = sanitisedFocusPoint(resolved, geometry: geometry)

    guard
      let previousContext = geometry.viewportContext(
        zoom: CGFloat(previousZoom),
        pan: interactionState.transform.panState.pan
      )
    else { return currentZoom }

    let focusCanvas = previousContext.toCanvas(
      screenPoint: Point<ScreenSpace>(fromPoint: focus)
    )

    guard
      let newContextZeroPan = geometry.viewportContext(
        zoom: CGFloat(nextZoom),
        pan: .zero
      )
    else { return currentZoom }

    let focusGlobalAtZeroPan = newContextZeroPan.toGlobal(point: focusCanvas.cgPoint)

    let proposedPan = CGSize(
      width: focus.x - focusGlobalAtZeroPan.x,
      height: focus.y - focusGlobalAtZeroPan.y
    )

    interactionState.transform.panState.value = clampedPan(
      proposedPan,
      at: nextZoom,
      interactionState: interactionState,
      geometry: geometry
    )
    return interactionState.transform.zoomState.zoom
  }
}

extension CanvasHandler {
  fileprivate func clearLatchedZoomFocusIfNeeded(
    for phase: InteractionPhase,
    interactionState: inout InteractionState
  ) {
    guard !phase.isActive else { return }
    interactionState.transform.latchedZoomFocusGlobal = nil
  }
}

extension CanvasHandler {
  private func clampedProposedZoom(
    _ proposedZoom: Double,
    currentZoom: Double,
    in zoomRange: ClosedRange<Double>?
  ) -> Double {
    guard proposedZoom.isFinite else {
      return currentZoom.clampedIfNeeded(to: zoomRange)
    }
    return proposedZoom.clampedIfNeeded(to: zoomRange)
  }

  private func clampedPan(
    _ proposedPan: CGSize,
    at zoom: Double,
    interactionState: InteractionState,
    geometry: CanvasGeometry
  ) -> CGSize {
    var candidate = interactionState.transform.panState
    candidate.value = proposedPan
    return candidate.clamped(to: geometry, zoom: CGFloat(zoom))
  }

  private func sanitisedFocusPoint(
    _ point: CGPoint,
    geometry: CanvasGeometry
  ) -> CGPoint {
    guard point.x.isFinite, point.y.isFinite else {
      return CGPoint(
        x: geometry.viewportRect.midX,
        y: geometry.viewportRect.midY
      )
    }
    return point
  }

  private func isZoomSafe(
    in geometry: CanvasGeometry,
    prev previousZoom: Double,
    next nextZoom: Double
  ) -> Bool {
    geometry.isValidForCoordinateMapping
      && previousZoom.isFinite && nextZoom.isFinite
      && previousZoom > 0 && nextZoom > 0
      && abs(nextZoom - previousZoom) > .ulpOfOne
  }
}
