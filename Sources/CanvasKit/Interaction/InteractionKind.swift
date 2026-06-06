//
//  InputKinds.swift
//  CanvasKit
//
//  Created by Dave Coleman on 20/3/2026.
//

/// The input source for a canvas interaction.
///
/// Swipe, pinch, and rotate are viewport gestures. Tap, drag, and hover are
/// pointer events captured in viewport coordinates and, where needed, mapped
/// into ``CanvasSpace``.
extension Interaction {
  public enum Kind: CaseIterable, Hashable, Sendable {
    
    // Viewport gestures
    case swipe
    case pinch
    case rotate
    
    // Pointer events
    case tap
    case drag
    case hover
  }
}

extension Interaction.Kind: CustomStringConvertible {
  public var description: String {
    switch self {
      case .swipe: "Swipe"
      case .pinch: "Pinch"
      case .rotate: "Rotate"
      case .tap: "Tap"
      case .drag: "Drag"
      case .hover: "Hover"
    }

  }
}
