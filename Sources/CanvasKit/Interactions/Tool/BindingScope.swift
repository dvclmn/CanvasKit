//
//  ToolBehaviour.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 10/3/2026.
//

import SwiftUI
import InteractionKit
import BasePrimitives

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
