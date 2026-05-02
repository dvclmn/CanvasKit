//
//  ToolPointerContext.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 18/3/2026.
//

import Foundation
import InputPrimitives

/// Describes the current interaction, as it is happening right now.
/// Can be used to compare against ``ToolCapability``s to
/// determine user intent based on the selected ``CanvasTool``.
public struct InteractionContext: Sendable {
  public let interaction: Interaction
  public let phase: InteractionPhase
  public let modifiers: Modifiers

  public init(
    interaction: Interaction,
    phase: InteractionPhase,
    modifiers: Modifiers,
  ) {
    self.interaction = interaction
    self.phase = phase
    self.modifiers = modifiers
  }
}

extension InteractionContext {
  public func withModifiers(_ modifiers: Modifiers) -> Self {
    .init(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
    )
  }

  public var isPointerDragging: Bool {
    guard case .drag = interaction else { return false }
    return phase.isActive
  }
}

extension InteractionContext: CustomStringConvertible {
  public var description: String {
    """
    Interaction: \(interaction)
    Phase: \(phase.name)
    Modifiers: \(modifiers)
    """
  }
}
