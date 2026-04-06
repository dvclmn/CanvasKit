//
//  ToolActivation.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 13/3/2026.
//

import SwiftUI

/// A record of a tool activation in progress (key held down).
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
public struct ToolActivation: Sendable {
  public let tool: any CanvasTool
  public let binding: ToolBinding
  public let startedAt: Date
  public let key: KeyEquivalent

  /// Whether the spring-load delay has elapsed and this activation is live.
  public var isArmed: Bool

  public init(
    tool: any CanvasTool,
    binding: ToolBinding,
    startedAt: Date = Date(),
    key: KeyEquivalent,
    isArmed: Bool = false
  ) {
    self.tool = tool
    self.binding = binding
    self.startedAt = startedAt
    self.key = key
    self.isArmed = isArmed
  }
}

/// Identity is determined by binding + key + start time, not by the tool itself.
extension ToolActivation: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.binding == rhs.binding
      && lhs.key == rhs.key
      && lhs.startedAt == rhs.startedAt
      && lhs.isArmed == rhs.isArmed
  }
}

extension ToolActivation: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(binding)
    hasher.combine(key)
    hasher.combine(startedAt)
    hasher.combine(isArmed)
  }
}
