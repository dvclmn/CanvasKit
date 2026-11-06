//
//  ToolResolution.swift
//  CanvasKit
//
//  Created by Dave Coleman on 18/3/2026.
//

import Foundation

/// Describes whether a tool consumed an interaction or yielded to CanvasKit's
/// default behaviour.
///
/// A consumed interaction skips CanvasKit's default behaviour regardless of
/// whether the tool requests an adjustment. CanvasKit still records any
/// independent pointer observation for the interaction.
public enum ToolResolution: Sendable {

  /// The tool consumed the interaction and supplied an adjustment to apply.
  /// Use ``ToolResolution/consumed`` when there is no adjustment to apply.
  case handled(InteractionAdjustment?)

  /// The tool does not claim this interaction. Fall through to canvas defaults.
  case passthrough
}

extension ToolResolution {
  /// The tool consumed the interaction, skipping the default behaviour
  /// without requesting a CanvasKit-owned pointer or transform mutation.
  ///
  /// Use this when the observable event itself is the result, such as Select's
  /// marquee drag. CanvasKit still publishes that drag independently through
  /// ``CanvasDragEvent``.
  public static var consumed: Self { .handled(nil) }
}
