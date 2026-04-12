//
//  InteractionAdjustment.swift
//  InteractionKit
//
//  Created by Dave Coleman on 8/4/2026.
//

//import InteractionKit
import BasePrimitives

/// Provides an interface for a Canvas Tool to describe how it
/// should mutate Canvas state when it performs some action.
///
/// Additional context is passed to the tool using ``Inter``
///
/// See ``CanvasTool/resolvePointerInteraction(context:currentTransform:)``
public enum InteractionAdjustment: Sendable {
  case transform(TransformAdjustment)
  case pointer(PointerAdjustment)
  case none
}

extension InteractionAdjustment {

  static func pointer(from drag: PointerDragPayload) -> Self {
    guard let rect = drag.boundingRect else { return .none }
    return .pointer(.drag(rect))
  }

  func isSupported(by interaction: InteractionKinds.Element) -> Bool {
    switch self {
      case .transform(let adjustment):
        adjustment.supportedInteractions.contains(interaction)

      case .pointer:
        /// Pointer adjustments have no support limitations
        true

      case .none: true
    }
  }
}
