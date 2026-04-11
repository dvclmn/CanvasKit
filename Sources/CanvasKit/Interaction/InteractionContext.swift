//
//  ToolPointerContext.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 18/3/2026.
//

import BasePrimitives
import Foundation

public struct InteractionContext: Sendable {
  public let interaction: Interaction
  public let phase: InteractionPhase
  public let modifiers: Modifiers

  public init(
    interaction: Interaction,
    phase: InteractionPhase = .none,
    modifiers: Modifiers,
  ) {
    self.interaction = interaction
    self.phase = phase
    self.modifiers = modifiers
  }
}

extension InteractionContext {
  /// True when the last pointer interaction is an active drag.
  public var isPointerDragging: Bool {
    guard case .drag = interaction else { return false }
    return phase.isActive
  }
}
