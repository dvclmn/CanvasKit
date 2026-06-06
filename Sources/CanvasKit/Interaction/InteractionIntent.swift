//
//  InteractionIntent.swift
//  CanvasKit
//
//  Created by Dave Coleman on 28/4/2026.
//

/// A way to attach meaning to a user interaction
public enum InteractionIntent: String, Sendable {

  case pan
  case zoom
  case rotate

  case adjustBrushSize

  // These two are undefined currently, need work
  case select
  case drawMarquee

  // Don't know how to handle this one yet
  case custom  // undefined
}

extension InteractionIntent: CustomStringConvertible {
  public var description: String {
    switch self {
      case .adjustBrushSize: "Adjust Brush Size"
      case .drawMarquee: "Draw Marquee"
      default: rawValue.capitalized
    }
  }
}
