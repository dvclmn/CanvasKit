//
//  ToolPointerContext.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 18/3/2026.
//

import BasePrimitives
import Foundation
import InteractionKit

public struct InteractionContext: Sendable {
  public let source: InteractionSource?
  public let phase: InteractionPhase
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
