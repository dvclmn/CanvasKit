//
//  ToolBehaviour.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 10/3/2026.
//

import SwiftUI
import InteractionPrimitives

/// Whether a binding applies everywhere or only when a specific tool is active.
public enum BindingScope: Sendable, Hashable {
  /// Applies regardless of current tool.
  case global

  /// Applies only when the specified tool is active.
  case tool(CanvasToolKind)
}

/// A key (with optional modifiers) that can trigger a `ToolBinding`.
public struct KeyBinding: Hashable, Sendable {
  public let key: KeyEquivalent
  public let requiredModifiers: Modifiers

  public init(
    key: KeyEquivalent,
    requiredModifiers: Modifiers = []
  ) {
    self.key = key
    self.requiredModifiers = requiredModifiers
  }
}
