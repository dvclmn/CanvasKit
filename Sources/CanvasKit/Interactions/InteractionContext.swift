//
//  ToolPointerContext.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 18/3/2026.
//

import Foundation
import BasePrimitives
import InteractionKit

/// Context used by tools to resolve a pointer style for the current interaction state.
public struct InteractionContext: Sendable {

  /// The most recent pointer interaction source, if any.
  public let source: InteractionSource?

  /// The most recent pointer interaction phase.
  public let phase: InteractionPhase

  /// Current modifier keys state.
  public let modifiers: Modifiers

  public init(
    source: InteractionSource? = nil,
    phase: InteractionPhase = .none,
    modifiers: Modifiers,
  ) {
    self.source = source
    self.phase = phase
    self.modifiers = modifiers
  }
}

extension InteractionContext {
  /// True when the last pointer interaction is an active drag.
  public var isPointerDragging: Bool {
    guard case .pointerDragGesture? = source else { return false }
    return phase.isActive
  }
}
