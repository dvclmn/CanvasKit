//
//  InteractionAdjustment.swift
//  InteractionKit
//
//  Created by Dave Coleman on 8/4/2026.
//

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

  var kind: AdjustmentKind? {
    switch self {
      case .transform(let adjustment):
        switch adjustment {
          case .translation: .translation
          case .scale: .scale
          case .rotation: .rotation
        }

      case .pointer(let adjustment):
        switch adjustment {
          case .tap: .tapLocation
          case .hover: .hoverLocation
          case .drag: .dragRect
        }

      case .none:
        nil
    }
  }

  static func pointerAdjustment(from drag: PointerDragPayload) -> Self {
    guard let rect = drag.boundingRect else { return .none }
    return .pointer(.drag(rect))
  }

  func isSupported(by interaction: InteractionKind) -> Bool {
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

extension InteractionAdjustment: CustomStringConvertible {
  public var description: String {
    switch self {
      case .transform(let adj): "Transform: \(adj)"
      case .pointer(let adj): "Pointer: \(adj)"
      case .none: "None"
    }
  }
}
