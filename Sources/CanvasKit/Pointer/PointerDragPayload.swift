//
//  PointerDragPayload.swift
//  CanvasKit
//
//  Created by Dave Coleman on 19/3/2026.
//

import Foundation

public enum PointerDragPayload: Sendable, Equatable {

  /// Frame-to-frame movement for continuous tools such as Pan and Zoom.
  case delta(Size<ViewportSpace>, location: Point<ViewportSpace>)

  /// Ordered anchor/current locations for marquee-style tools.
  case rect(from: Point<ViewportSpace>, current: Point<ViewportSpace>)
}

extension PointerDragPayload: CustomStringConvertible {
  public var description: String {
    switch self {
      case .delta(let size, let location): "Delta[size: \(size), location: \(location)]"
      case .rect(let from, let current): "Rect[from: \(from), current: \(current)]"
    }
  }
}
