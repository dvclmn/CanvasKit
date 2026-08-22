//
//  ToolCapability.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

private import ViewTools
private import CoreTools
import SwiftUI

/// Declares an interaction that a tool is willing to resolve and the semantic
/// intent the tool assigns to it.
///
/// `modifiers == nil` matches regardless of modifier state. When modifiers are
/// provided, the current event modifiers must contain them. Additional active
/// modifiers do not prevent a match.
public struct ToolCapability: Sendable, Equatable {
  public let interactionKind: Interaction.Kind
  public let intent: InteractionIntent
  public let modifiers: EventModifiers?

  public init(
    interaction: Interaction.Kind,
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

  /// A capability requiring more modifiers is a more specific interpretation
  /// of the same physical interaction.
  fileprivate var specificity: Int {
    modifiers?.rawValue.nonzeroBitCount ?? 0
  }
}

extension Collection where Element == ToolCapability {
  /// Returns the most specific matching capability while preserving declaration
  /// order as the tie-breaker.
  ///
  /// For example, an Option-drag capability wins over an unmodified drag
  /// capability while Option is held. Two equally specific declarations retain
  /// the order chosen by the tool author.
  func bestMatch(for context: InteractionContext) -> ToolCapability? {
    var bestMatch: ToolCapability?
    var bestSpecificity = -1

    for capability in self where capability.matches(context) {
      guard capability.specificity > bestSpecificity else { continue }
      bestMatch = capability
      bestSpecificity = capability.specificity
    }

    return bestMatch
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
