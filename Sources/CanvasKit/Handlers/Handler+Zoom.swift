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
  let resolver: ZoomFocusResolver
  let zoomRange: ClosedRange<Double>?
}

// MARK: - Main update

extension ZoomHandler {
  
  
  @discardableResult
  func updateZoom(interactionState: inout CanvasInteraction) -> Double {
    defer { clearLatchedZoomFocusIfNeeded(for: zoomEvent.phase, interactionState: &interactionState) }

    let currentZoom = interactionState.zoom

    let previousZoom = clampedProposedZoom(zoomEvent.previousZoom, currentZoom: currentZoom)
    let nextZoom = clampedProposedZoom(zoomEvent.proposedZoom, currentZoom: currentZoom)

    interactionState.transform.zoom.update(nextZoom, phase: zoomEvent.phase)

    guard isZoomSafe(prev: previousZoom, next: nextZoom),
      let resolved = resolver.resolved(
        for: zoomEvent.phase,
        pointerLocation: interactionState.pointer.hover.value,
        transform: &interactionState.transform,
        geometry: geometry
      )
    else { return currentZoom }

    let focus = sanitisedFocusPoint(resolved)

    guard
      let previousContext = geometry.viewportContext(
        zoom: CGFloat(previousZoom),
        pan: interactionState.pan
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

    interactionState.transform.pan.value = clampedPan(
      proposedPan,
      at: nextZoom,
      interactionState: interactionState
    )
    return interactionState.zoom
  }
}

// MARK: - Helpers

extension ZoomHandler {
  private func clearLatchedZoomFocusIfNeeded(
    for phase: InteractionPhase,
    interactionState: inout CanvasInteraction
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
    _ proposedPan: CGSize,
    at zoom: Double,
    interactionState: CanvasInteraction
  ) -> CGSize {
    var candidate = interactionState.transform.pan
    candidate.value = proposedPan
    return candidate.clamped(to: geometry, zoom: CGFloat(zoom))
  }

  private func sanitisedFocusPoint(_ point: CGPoint) -> CGPoint {
    guard point.x.isFinite, point.y.isFinite else {
      return CGPoint(x: geometry.viewportRect.midX, y: geometry.viewportRect.midY)
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
