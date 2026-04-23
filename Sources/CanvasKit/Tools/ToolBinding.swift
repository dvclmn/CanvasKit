//
//  ToolBinding.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 13/3/2026.
//


import SwiftUI
import InputPrimitives

/// Maps a key input to a tool activation with a given mode.
///
/// Bindings are the single source of truth for "which key activates which tool".
/// `CanvasTool` intentionally does not store shortcut keys — that's this type's job.
///
/// A single tool can have multiple bindings (e.g. Pan has both "H" sticky and Space hold).
public struct ToolBinding: Hashable, Sendable {
  public let shortcut: KeyboardShortcut
  public let target: CanvasToolKind
  public let mode: ActivationMode

  public init(
    _ shortcut: KeyboardShortcut,
    target: CanvasToolKind,
    mode: ActivationMode,
  ) {
    self.shortcut = shortcut
    self.target = target
    self.mode = mode
  }
}

extension ToolBinding {
  var modifiers: Modifiers { .init(from: shortcut.modifiers) }

}

extension KeyboardShortcut {
  static func keyOnly(_ key: KeyEquivalent) -> Self {
    .init(key, modifiers: [])
  }
}
