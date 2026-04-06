//
//  ToolOverride.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 13/3/2026.
//

import SwiftUI

/// A transient tool override in progress (key held down).
///
/// Behaviour depends on the binding's `ActivationMode`:
///
/// - `.hold` (e.g. Space → Pan): Arms immediately. The tool is active
///   for as long as the key is held and reverts on release — a brief tap
///   has no lasting effect.
///
/// - `.sticky` (e.g. H → Pan): Starts unarmed. If the key is released
///   quickly (before `springLoadDelay`), the tool *commits* as the new base
///   tool. If held longer, it arms as a spring-load and reverts on release —
///   just like `.hold`.
public struct ToolOverride: Hashable, Sendable {
  public let binding: ToolBinding
  public let startedAt: Date
  public let key: KeyEquivalent

  /// Whether the spring-load delay has elapsed and this override is live.
  public var isArmed: Bool

  public init(
    binding: ToolBinding,
    startedAt: Date = Date(),
    key: KeyEquivalent,
    isArmed: Bool = false
  ) {
    self.binding = binding
    self.startedAt = startedAt
    self.key = key
    self.isArmed = isArmed
  }
}
