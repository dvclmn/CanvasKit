//
//  InteractionContext.swift
//  CanvasKit
//
//  Created by Dave Coleman on 18/3/2026.
//

private import CoreTools
import SwiftUI
private import ViewTools

/// Describes one interaction update as it is being processed.
///
/// CanvasKit first creates a context containing the physical interaction,
/// lifecycle phase, and modifiers. Tool routing then attaches the selected
/// ``matchedCapability`` before calling ``CanvasTool``. This keeps physical
/// input separate from the semantic ``intent`` assigned by the effective tool.
public struct InteractionContext: Sendable {
  public let interaction: Interaction
  public let phase: InteractionPhase
  public let modifiers: EventModifiers

  /// The capability selected by CanvasKit for this tool callback.
  ///
  /// This is `nil` for an unresolved context and for CanvasKit default handling.
  /// When several capabilities match, CanvasKit chooses the declaration with
  /// the greatest number of required modifiers and preserves declaration order
  /// as the tie-breaker.
  public let matchedCapability: ToolCapability?

  /// The semantic intent of ``matchedCapability``, when tool routing matched one.
  public var intent: InteractionIntent? { matchedCapability?.intent }

  public init(
    interaction: Interaction,
    phase: InteractionPhase,
    modifiers: EventModifiers,
  ) {
    self.interaction = interaction
    self.phase = phase
    self.modifiers = modifiers
    self.matchedCapability = nil
  }
}

extension InteractionContext {
  private init(
    interaction: Interaction,
    phase: InteractionPhase,
    modifiers: EventModifiers,
    matchedCapability: ToolCapability?,
  ) {
    self.interaction = interaction
    self.phase = phase
    self.modifiers = modifiers
    self.matchedCapability = matchedCapability
  }

  public func withModifiers(_ modifiers: EventModifiers) -> Self {
    .init(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
      matchedCapability: matchedCapability,
    )
  }

  public func withPhase(_ phase: InteractionPhase) -> Self {
    .init(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
      matchedCapability: matchedCapability,
    )
  }

  func matching(_ capability: ToolCapability) -> Self {
    .init(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
      matchedCapability: capability,
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
    Phase: \(phase.displayName)
    Modifiers: \(modifiers)
    Intent: \(intent?.description ?? "Unresolved")
    """
  }
}
