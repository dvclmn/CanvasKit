//
//  ToolCapability.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

import ViewTools

/// A Tool Capability allows the tool author to declare what should happen
/// when a user performs one of the six ``InteractionKind``s.
public struct ToolCapability: Hashable, Sendable {
  public let interactionKind: InteractionKind
  public let intent: InteractionIntent
  public let modifiers: Modifiers?

  public init(
    interaction: InteractionKind,
    intent: InteractionIntent? = nil,
    modifiers: Modifiers? = nil,
  ) {
    self.interactionKind = interaction
    self.intent = intent ?? .custom
    self.modifiers = modifiers
  }
}

extension ToolCapability {
  func matches(_ context: InteractionContext) -> Bool {
    guard interactionKind == context.interaction.kind else { return false }
    guard let modifiers else { return true }
    return context.modifiers.contains(modifiers)
  }
}

extension ToolCapability: CustomStringConvertible {
  public var description: String {
    DisplayString {
      Labeled("Interaction", value: interactionKind)
      Labeled("Intent", value: intent)
      Labeled("Modifiers", value: modifiers)
    }.text
  }
}
