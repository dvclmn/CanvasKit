//
//  PointerDragPayload.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 19/3/2026.
//

import GeometryPrimitives
import Foundation

public enum PointerDragPayload: Sendable, Equatable {

  /// For panning/continuous
  case delta(Size<ViewportSpace>, location: Point<ViewportSpace>)

  /// For marquee/select
  case rect(from: Point<ViewportSpace>, current: Point<ViewportSpace>)
}

extension PointerDragPayload {

  public var boundingRect: Rect<ViewportSpace>? {
    switch self {
      case .delta: nil
      case .rect(let from, let current): Rect<ViewportSpace>(from: from, to: current)
    }
  }
}

extension PointerDragPayload: CustomStringConvertible {
  public var description: String {
    switch self {
      case .delta(let size, let location): "Delta[size: \(size), location: \(location)]"
      case .rect(let from, let current): "Rect[from: \(from), current: \(current)]"
    }
  }
}
