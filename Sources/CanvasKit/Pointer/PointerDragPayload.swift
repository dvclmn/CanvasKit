//
//  PointerDragPayload.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 19/3/2026.
//

import CanvasCore
import Foundation

public enum PointerDragPayload: Sendable, Equatable {

  /// For panning/continuous
  case delta(Size<ScreenSpace>, location: Point<ScreenSpace>)

  /// For marquee/select
  case rect(from: Point<ScreenSpace>, current: Point<ScreenSpace>)
}

extension PointerDragPayload {

//  public var name: String {
//    
//  }

  public var boundingRect: Rect<ScreenSpace>? {
    switch self {
      case .delta: nil
      case .rect(let from, let current): Rect<ScreenSpace>(from: from, to: current)
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
