//
//  PointerAdjustment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 8/4/2026.
//

/// Updates pointer-derived canvas state such as tap, hover, and drag values.
public enum PointerAdjustment: Sendable {
  case tap(Point<ViewportSpace>)
  case hover(Point<ViewportSpace>)
  case drag(Rect<ViewportSpace>)
}

extension PointerAdjustment: CustomStringConvertible {
  public var description: String {
    switch self {
      case .tap(let point): "Tap \(point)"
      case .hover(let point): "Hover \(point)"
      case .drag(let rect): "Drag \(rect)"
    }
  }
}
