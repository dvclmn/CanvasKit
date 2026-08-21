//
//  InteractionAdjustment.swift
//  InteractionKit
//
//  Created by Dave Coleman on 8/4/2026.
//

/// Describes a state change produced by an interaction or tool.
///
/// See ``CanvasTool/resolveInteraction(context:currentTransform:)``.
public enum InteractionAdjustment: Sendable {
  case transform(TransformAdjustment)
  case pointer(PointerAdjustment)
  case none
}

extension InteractionAdjustment {

//  static func pointerAdjustment(from drag: PointerDragPayload) -> Self {
//    guard let rect = drag.boundingRect else { return .none }
//    return .pointer(.drag(rect))
//  }
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
