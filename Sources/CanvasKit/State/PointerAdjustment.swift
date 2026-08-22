//
//  PointerAdjustment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 8/4/2026.
//

/// Requests a CanvasKit-owned pointer-state update.
///
/// Marquee drag observation is recorded directly from ``PointerDragPayload``
/// and published as ``CanvasDragEvent`` rather than passing through this type.
public enum PointerAdjustment: Sendable {
  case tap(Point<ViewportSpace>)
  case hover(Point<ViewportSpace>)
}

extension PointerAdjustment: CustomStringConvertible {
  public var description: String {
    switch self {
      case .tap(let point): "Tap \(point)"
      case .hover(let point): "Hover \(point)"
    }
  }
}
