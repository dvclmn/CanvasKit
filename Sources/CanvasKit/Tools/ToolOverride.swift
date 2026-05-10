//
//  ToolOverride.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 13/3/2026.
//

import SwiftUI

/// A transient key-held tool override.
///
/// Behaviour depends on the binding's `ToolActivationMode`:
///
/// - `.hold` (e.g. Space → Pan): Arms immediately. The tool is active
///   for as long as the key is held and reverts on release — a brief tap
///   has no lasting effect.
///
/// - `.sticky` (e.g. H → Pan): Becomes effective immediately, but starts
///   unarmed. If the key is released quickly (before `springLoadDelay`), the
///   tool commits as the new base tool. If held longer, it arms as a
///   spring-load and reverts on release.
public struct ToolOverride: Hashable, Sendable {
  public let binding: ToolBinding
  public let startedAt: Date
  public let key: KeyEquivalent

  /// Whether this override has crossed into spring-load/revert-on-release state.
  ///
  /// For `.hold`, this is `true` from key-down. For `.sticky`, this becomes
  /// `true` only after `springLoadDelay` has elapsed while the key is still held.
  public var isArmed: Bool

  public init(
    binding: ToolBinding,
    startedAt: Date = Date(),
    key: KeyEquivalent,
    isArmed: Bool = false,
  ) {
    self.binding = binding
    self.startedAt = startedAt
    self.key = key
    self.isArmed = isArmed
  }
}
