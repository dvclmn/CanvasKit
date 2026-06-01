//
//  ToolCapability.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

private import ViewTools
private import CoreTools
import SwiftUI

/// Declares an interaction kind that a tool is willing to resolve.
///
/// `modifiers == nil` matches regardless of modifier state. When modifiers are
/// provided, the current event modifiers must contain them for the capability to
/// match.
public struct ToolCapability: Sendable {
  public let interactionKind: InteractionKind
  public let intent: InteractionIntent
  public let modifiers: EventModifiers?

  public init(
    interaction: InteractionKind,
    intent: InteractionIntent? = nil,
    modifiers: EventModifiers? = nil,
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
