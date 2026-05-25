//
//  ToolCapability.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

import ViewTools
import CoreTools
import SwiftUI

/// A Tool Capability allows the tool author to declare what should happen
/// when a user performs one of the six ``InteractionKind``s.
public struct ToolCapability: Sendable {
  public let interactionKind: InteractionKind
  public let intent: InteractionIntent
  public let modifiers: EventModifiers?
//  public let modifiers: Modifiers?

  public init(
    interaction: InteractionKind,
    intent: InteractionIntent? = nil,
    modifiers: EventModifiers? = nil,
//    modifiers: Modifiers? = nil,
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
    """
    Interaction: \(interactionKind)
    Intent: \(intent)
    Modifiers: \(String(describing: modifiers))
    """
  }
}
