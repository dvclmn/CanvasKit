//
//  InteractionIntent.swift
//  CanvasKit
//
//  Created by Dave Coleman on 28/4/2026.
//

/// The semantic meaning a tool assigns to a matched physical interaction.
///
/// Intent is resolved from ``ToolCapability`` rather than inferred from the
/// interaction kind. A drag can therefore mean pan, zoom, marquee selection,
/// or an app-defined operation depending on the effective tool and modifiers.
public enum InteractionIntent: String, Sendable, Equatable {

  case pan
  case zoom
  case rotate

  case adjustBrushSize

  case select
  case drawMarquee

  /// An app-defined meaning that CanvasKit does not interpret itself.
  case custom
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
