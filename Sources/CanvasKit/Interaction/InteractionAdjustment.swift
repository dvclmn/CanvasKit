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

  static func pointerAdjustment(from drag: PointerDragPayload) -> Self {
    guard let rect = drag.boundingRect else { return .none }
    return .pointer(.drag(rect))
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
