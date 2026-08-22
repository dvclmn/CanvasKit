//
//  ToolResolution.swift
//  CanvasKit
//
//  Created by Dave Coleman on 18/3/2026.
//

import Foundation

/// Describes whether a tool consumed an interaction or yielded to CanvasKit's
/// default behaviour.
public enum ToolResolution: Sendable {

  /// The tool consumed this interaction and optionally requested an adjustment.
  case handled(InteractionAdjustment)

  /// The tool does not claim this interaction. Fall through to canvas defaults.
  case passthrough
}

extension ToolResolution {
  /// The tool consumed the interaction without requesting a CanvasKit-owned
  /// pointer or transform mutation.
  ///
  /// Use this when the observable event itself is the result, such as Select's
  /// marquee drag. CanvasKit still publishes that drag independently through
  /// ``CanvasDragEvent``.
  public static var consumed: Self { .handled(.none) }
}
