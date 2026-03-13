//
//  ZoomFocusResolver.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 7/3/2026.
//

import BasePrimitives
import Foundation

//public enum ZoomFocusResolver: String, Sendable, Equatable, CaseIterable {
//  /// Locks to the first available focus point for the whole pinch gesture.
//  /// This avoids jumpy behaviour if hover briefly drops out mid-gesture.
//  case latchedPointerOrViewportCentre
//
//  /// Re-evaluates focus continuously using pointer hover, then viewport centre fallback.
//  case pointerOrViewportCentre
//
//  /// Always zoom around viewport centre.
//  case viewportCentre
//}
//
//extension ZoomFocusResolver {
//  func resolved(
//    for phase: InteractionPhase,
//    pointerLocation: CGPoint?,
//    transform: inout TransformState,
//    geometry: CanvasGeometry,
//    //    pointerLocationGlobal: CGPoint?
//  ) -> CGPoint? {
//    //    guard let geometry else { return nil  }
//
//    //    let pointerLocation = pointer.pointerHover.value
//
//    let viewportCentre = geometry.viewportRect.midpoint
//    switch self {
//      case .latchedPointerOrViewportCentre:
//        if let latched = transform.latchedZoomFocusGlobal {
//          return latched
//        }
//
//        let resolved = pointerLocation ?? viewportCentre
//
//        if phase.isActive {
//          transform.latchedZoomFocusGlobal = resolved
//        }
//        return resolved
//
//      case .pointerOrViewportCentre:
//        return pointerLocation ?? viewportCentre
//
//      case .viewportCentre:
//        return viewportCentre
//    }
//  }
//}
