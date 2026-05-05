//
//  ToolActivationStatus.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/5/2026.
//

/// Describes the runtime state of a key-held tool override.
///
/// This is intentionally separate from ``ActivationMode``:
/// `ActivationMode` describes the configured behaviour of a binding, while
/// `ToolActivationStatus` describes what is happening right now.
enum ToolActivationStatus: Sendable, Hashable {

  /// A hold-only override, such as Space -> Pan.
  ///
  /// The target tool is active only while the key is held. Releasing the key
  /// always returns to the committed tool and never commits the target.
  case nonCommittingHold

  /// A sticky shortcut is currently held but has not crossed the spring-load
  /// threshold yet.
  ///
  /// Releasing now will commit the target tool.
  case heldPendingCommitOrRelease

  /// A sticky shortcut has crossed the spring-load threshold.
  ///
  /// Releasing now will revert to the previous committed tool.
  case springLoaded
}
