//
//  Handler+Zoom.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 7/3/2026.
//

import BasePrimitives
import Foundation

//struct ZoomHandler {
//  let zoomEvent: ZoomGestureEvent
//  let geometry: CanvasGeometry
//  let zoomRange: ClosedRange<Double>?
//}
//
//// MARK: - Main update
//
//extension ZoomHandler {
//
//  @discardableResult
//  func updateZoom(
//    pointerHover:
//    state: inout CanvasInteractionState
//  ) -> Double {
//    defer {
//      clearLatchedZoomFocusIfNeeded(
//        for: zoomEvent.phase,
//        interactionState: &state
//      )
//    }
//
//    let currentZoom = state.zoom
//
//    let previousZoom = clampedProposedZoom(zoomEvent.previousZoom, currentZoom: currentZoom)
//    let nextZoom = clampedProposedZoom(zoomEvent.proposedZoom, currentZoom: currentZoom)
//
//    state.transform.zoom.update(nextZoom, phase: zoomEvent.phase)
//
//    guard isZoomSafe(prev: previousZoom, next: nextZoom)
//    //      let resolved = resolver.resolved(
//    //        for: zoomEvent.phase,
//    //        pointerLocation: state.pointer.hover.value,
//    //        transform: &state.transform,
//    //        geometry: geometry
//    //      )
//    else { return currentZoom }
//
//    let hover = state.pointer.hover.value
//    let focusLocation = sanitisedFocusPoint(hover) ?? geometry.viewportRect.midpoint.cgPoint
//
//    guard
//      let previousContext = geometry.viewportMapping(
//        zoom: CGFloat(previousZoom),
//        pan: state.transform.pan.value
//      )
//    else { return currentZoom }
//
//    let focusCanvas = previousContext.toCanvas(screenPoint: focusLocation)
//
//    guard
//      let newContextZeroPan = geometry.viewportMapping(
//        zoom: CGFloat(nextZoom),
//        pan: .zero
//      )
//    else { return currentZoom }
//
//    let focusGlobalAtZeroPan = newContextZeroPan.toGlobal(point: focusCanvas.cgPoint)
//
//    let proposedPan = Size<ScreenSpace>(
//      //    let proposedPan = CGSize(
//      width: focusLocation.x - focusGlobalAtZeroPan.x,
//      height: focusLocation.y - focusGlobalAtZeroPan.y
//    )
//
//    state.transform.pan.value = clampedPan(
//      proposedPan,
//      at: nextZoom,
//      state: state
//    )
//    return state.zoom
//  }
//}
//
//// MARK: - Helpers
//
//extension ZoomHandler {
//  private func clearLatchedZoomFocusIfNeeded(
//    for phase: InteractionPhase,
//    interactionState: inout CanvasInteractionState
//  ) {
//    guard !phase.isActive else { return }
//    interactionState.transform.latchedZoomFocusGlobal = nil
//  }
//
//  private func clampedProposedZoom(
//    _ proposedZoom: Double,
//    currentZoom: Double
//  ) -> Double {
//    let zoomResult = proposedZoom.isFinite ? proposedZoom : currentZoom
//    return zoomResult.clampedIfNeeded(to: zoomRange)
//  }
//
//  private func clampedPan(
//    _ proposedPan: Size<ScreenSpace>,
//    //    _ proposedPan: CGSize,
//    at zoom: Double,
//    state: CanvasInteractionState
//  ) -> Size<ScreenSpace> {
//    //  ) -> CGSize {
//    var candidate = state.transform.pan
//    candidate.value = proposedPan
//    return candidate.clamped(to: geometry, zoom: CGFloat(zoom))
//  }
//
//  private func sanitisedFocusPoint(_ point: CGPoint?) -> CGPoint? {
//    guard let point, point.isFinite else { return nil }
//    return point
//  }
//
//  private func isZoomSafe(
//    prev previousZoom: Double,
//    next nextZoom: Double
//  ) -> Bool {
//    geometry.isValidForCoordinateMapping
//      && previousZoom.isFiniteAndGreaterThanZero
//      && nextZoom.isFiniteAndGreaterThanZero
//      && abs(nextZoom - previousZoom) > .ulpOfOne
//  }
//}
