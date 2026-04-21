//
//  ToolPointerContext.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 18/3/2026.
//

import CanvasCore
import Foundation
import InputPrimitives

public struct InteractionContext: Sendable {
  let interaction: Interaction
  let phase: InteractionPhase
  let modifiers: Modifiers

  init(
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
  var isPointerDragging: Bool {
    guard case .drag = interaction else { return false }
    return phase.isActive
  }
}

extension InteractionContext: CustomStringConvertible {
  public var description: String {
    "Interaction: \(interaction), Phase: \(phase.name), Modifiers: \(modifiers)"
  }
}
