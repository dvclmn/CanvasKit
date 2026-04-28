//
//  GestureIntent.swift
//  CanvasKit
//
//  Created by Dave Coleman on 28/4/2026.
//

/// Starting with finite/default intents at first
public enum GestureIntent: Sendable {

  /// Important: Need to see Modifiers to properly resolve. E.g. a Swipe
  /// gesture resolves to Pan by default; with Option it becomes Zoom.
  case pan
  case zoom
  case rotate

  case adjustBrushSize

  // These two are undefined currently, need work
  case select
  case drawMarquee
}
