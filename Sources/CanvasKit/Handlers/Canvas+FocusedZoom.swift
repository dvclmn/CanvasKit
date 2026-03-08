//
//  Canvas+FocusedZoom.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 1/3/2026.
//

import BasePrimitives
import GestureKit
import SwiftUI

//extension CanvasHandler {
//
//  fileprivate var zoomValue: Double { transform.zoomState.zoom }
//
//  /// Updates zoom while preserving the focused screen point.
//  /// This makes pinch/spread feel anchored to pointer intent instead of viewport centre.
//  @discardableResult
//  public func updateZoom(
//    using event: ZoomGestureEvent,
//    geometry: CanvasGeometry,
//    in zoomRange: ClosedRange<Double>?
//  ) -> Double {
//    defer { clearLatchedZoomFocusIfNeeded(for: event.phase) }
//
//    let previousZoom = clampedProposedZoom(event.previousZoom, in: zoomRange)
//    let nextZoom = clampedProposedZoom(event.proposedZoom, in: zoomRange)
//
//    transform.zoomState.update(nextZoom, phase: event.phase)
//
//    guard isZoomSafe(in: geometry, prev: previousZoom, next: nextZoom),
//      let resolved = zoomFocusResolver.resolved(
//        for: event.phase,
//        pointerLocation: pointer.pointerHover.value,
//        transform: &transform,
//        geometry: geometry
//      )
//    else { return zoomValue }
//
//    let focus = sanitisedFocusPoint(resolved, geometry: geometry)
//
//    guard
//      let previousContext = geometry.viewportContext(
//        zoom: CGFloat(previousZoom),
//        pan: transform.panState.pan
//      )
//    else { return zoomValue }
//
//    let focusCanvas = previousContext.toCanvas(
//      screenPoint: Point<ScreenSpace>(fromPoint: focus)
//    )
//
//    guard
//      let newContextZeroPan = geometry.viewportContext(
//        zoom: CGFloat(nextZoom),
//        pan: .zero
//      )
//    else { return zoomValue }
//
//    let focusGlobalAtZeroPan = newContextZeroPan.toGlobal(point: focusCanvas.cgPoint)
//
//    let proposedPan = CGSize(
//      width: focus.x - focusGlobalAtZeroPan.x,
//      height: focus.y - focusGlobalAtZeroPan.y
//    )
//
//    transform.panState.value = clampedPan(
//      proposedPan,
//      at: nextZoom,
//      geometry: geometry
//    )
//    return zoomValue
//  }
//}
//
//extension CanvasHandler {
//  private func clampedProposedZoom(
//    _ proposedZoom: Double,
//    in zoomRange: ClosedRange<Double>?
//  ) -> Double {
//    guard proposedZoom.isFinite else {
//      return zoomValue.clampedIfNeeded(to: zoomRange)
//    }
//    return proposedZoom.clampedIfNeeded(to: zoomRange)
//  }
//
//  private func clampedPan(
//    _ proposedPan: CGSize,
//    at zoom: Double,
//    geometry: CanvasGeometry
//  ) -> CGSize {
//    var candidate = transform.panState
//    candidate.value = proposedPan
//    return candidate.clamped(to: geometry, zoom: CGFloat(zoom))
//  }
//
//  private func sanitisedFocusPoint(
//    _ point: CGPoint,
//    geometry: CanvasGeometry
//  ) -> CGPoint {
//    guard point.x.isFinite, point.y.isFinite else {
//      return CGPoint(
//        x: geometry.viewportRect.midX,
//        y: geometry.viewportRect.midY
//      )
//    }
//    return point
//  }
//
//  private func isZoomSafe(
//    in geometry: CanvasGeometry,
//    prev previousZoom: Double,
//    next nextZoom: Double
//  ) -> Bool {
//    geometry.isValidForCoordinateMapping
//      && previousZoom.isFinite && nextZoom.isFinite
//      && previousZoom > 0 && nextZoom > 0
//      && abs(nextZoom - previousZoom) > .ulpOfOne
//  }
//}
