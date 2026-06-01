//
//  ToolBinding.swift
//  CanvasKit
//
//  Created by Dave Coleman on 13/3/2026.
//

private import ViewTools
private import CoreTools
import SwiftUI

/// Maps a key input to a tool activation with a given mode.
///
/// Bindings are the single source of truth for "which key activates which tool".
/// `CanvasTool` intentionally does not store shortcut keys — that's this type's job.
///
/// A single tool can have multiple bindings. For example, Pan can have both
/// an "H" sticky shortcut that may commit the tool, and a Space hold shortcut
/// that only spring-loads it temporarily.
public struct ToolBinding: Hashable, Sendable, Equatable {
  public let shortcut: KeyboardShortcut
  public let target: CanvasToolKind
  public let mode: ToolActivationMode

  public init(
    _ shortcut: KeyboardShortcut,
    target: CanvasToolKind,
    mode: ToolActivationMode,
  ) {
    self.shortcut = shortcut
    self.target = target
    self.mode = mode
  }
}

extension ToolBinding {
  var modifiers: EventModifiers { shortcut.modifiers }
//  var modifiers: Modifiers { .init(from: shortcut.modifiers) }

}

extension KeyboardShortcut {
  static func keyOnly(_ key: KeyEquivalent) -> Self {
    .init(key, modifiers: [])
  }
}

extension ToolBinding: CustomStringConvertible {
  public var description: String {
    """
    Shortcut: \(shortcut.description)
    Target Tool Kind: \(target)
    Activation Mode: \(mode.rawValue)
    """
  }
}

extension KeyboardShortcut {
  fileprivate var description: String {
    "\(Modifiers(from: modifiers).displayString)\(String(describing: key))"
  }
}
