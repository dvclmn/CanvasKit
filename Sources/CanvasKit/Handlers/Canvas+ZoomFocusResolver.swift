//
//  Canvas+ZoomFocusResolver.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 1/3/2026.
//

import CoreTools
import Foundation
import GestureKit

public enum ZoomFocusResolver: String, Sendable, Equatable, CaseIterable {
  /// Locks to the first available focus point for the whole pinch gesture.
  /// This avoids jumpy behaviour if hover briefly drops out mid-gesture.
  case latchedPointerOrViewportCentre

  /// Re-evaluates focus continuously using pointer hover, then viewport centre fallback.
  case pointerOrViewportCentre

  /// Always zoom around viewport centre.
  case viewportCentre
}

extension CanvasHandler {
  func resolvedZoomFocus(
    for phase: InteractionPhase
  ) -> CGPoint? {
    guard let geometry else { return nil  }
    let viewportCentre = CGPoint(
      x: geometry.viewportRect.midX,
      y: geometry.viewportRect.midY
    )

    switch zoomFocusResolver {
      case .latchedPointerOrViewportCentre:
        if let latched = transform.latchedZoomFocusGlobal {
          return latched
        }

        let resolved = pointerHoverGlobal ?? viewportCentre
        if phase.isActive {
          transform.latchedZoomFocusGlobal = resolved
        }
        return resolved

      case .pointerOrViewportCentre:
        return pointerHoverGlobal ?? viewportCentre

      case .viewportCentre:
        return viewportCentre
    }
  }

  func clearLatchedZoomFocusIfNeeded(
    for phase: InteractionPhase
  ) {
    guard !phase.isActive else { return }
    transform.latchedZoomFocusGlobal = nil
  }
}
