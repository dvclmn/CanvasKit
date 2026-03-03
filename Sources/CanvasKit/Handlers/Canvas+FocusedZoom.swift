//
//  Canvas+FocusedZoom.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 1/3/2026.
//

import CoreTools
import GestureKit
import SwiftUI

extension CanvasHandler {
  /// Updates zoom while preserving the focused screen point.
  /// This makes pinch/spread feel anchored to pointer intent instead of viewport centre.
  @discardableResult
  public func updateZoom(
    using event: ZoomGestureEvent
  ) -> Double {
    defer { clearLatchedZoomFocusIfNeeded(for: event.phase) }

    let previousZoom = clampedZoom(event.previousZoom)
    let nextZoom = clampedZoom(event.proposedZoom)
    
    

    zoomGesture.update(nextZoom, phase: event.phase)

    guard let geometry, geometry.isValidForCoordinateMapping,
      previousZoom.isFinite, nextZoom.isFinite,
      previousZoom > 0, nextZoom > 0,
      abs(nextZoom - previousZoom) > .ulpOfOne
    else { return zoomGesture.value }

    let focus = sanitisedFocusPoint(
      resolvedZoomFocus(for: event.phase)
    )

    guard let previousContext = geometry.viewportContext(
      zoom: CGFloat(previousZoom),
      pan: panGesture.pan
    ) else { return zoomGesture.value }

    let focusCanvas = previousContext.toCanvas(
      screenPoint: Point<ScreenSpace>(fromPoint: focus)
    )

    let focusCanvasPoint = CGPoint(x: focusCanvas.x, y: focusCanvas.y)

    guard let newContextZeroPan = geometry.viewportContext(
      zoom: CGFloat(nextZoom),
      pan: .zero
    )  else { return zoomGesture.value }
    let focusGlobalAtZeroPan = newContextZeroPan.toGlobal(point: focusCanvasPoint)

    let proposedPan = CGSize(
      width: focus.x - focusGlobalAtZeroPan.x,
      height: focus.y - focusGlobalAtZeroPan.y
    )

    panGesture.value = clampedPan(proposedPan, at: nextZoom)
    return zoomGesture.value
  }
}

extension CanvasHandler {
  private func clampedZoom(_ proposedZoom: Double) -> Double {
    guard proposedZoom.isFinite else {
      return zoomGesture.value.clampedIfNeeded(to: zoomRange)
    }
    return proposedZoom.clampedIfNeeded(to: zoomRange)
  }

  private func clampedPan(
    _ proposedPan: CGSize,
    at zoom: Double
  ) -> CGSize {
    guard let geometry else { return panGesture.pan }
    var candidate = panGesture
    candidate.value = proposedPan
    return candidate.clamped(to: geometry, zoom: CGFloat(zoom))
  }

  private func sanitisedFocusPoint(_ point: CGPoint) -> CGPoint {
    guard let geometry else { return point }
    guard point.x.isFinite, point.y.isFinite else {
      return CGPoint(
        x: geometry.viewportRect.midX,
        y: geometry.viewportRect.midY
      )
    }
    return point
  }
}
