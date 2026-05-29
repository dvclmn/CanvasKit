//
//  ToolActivationMode.swift
//  CanvasKit
//
//  Created by Dave Coleman on 6/4/2026.
//

public enum ToolActivationMode: String, Sendable, Hashable {
  
  /// Spring-load immediately while the key is held.
  ///
  /// Example: holding Space temporarily makes Pan the effective tool, then
  /// releases back to the committed tool when Space is lifted.
  case hold

  /// Shortcut behaviour with a quick-press commit and optional long-hold revert.
  ///
  /// On key-down, the target tool becomes effective immediately so interactions
  /// can use it right away. If the key is released before
  /// `ToolConfiguration.springLoadDelay`, the target is committed as the new
  /// base tool. If it is held beyond the delay, it arms as a spring-load and
  /// reverts on release.
  case sticky
  // Reserved for a future toggle mode once the runtime behaviour is defined.
//  case toggle
}
