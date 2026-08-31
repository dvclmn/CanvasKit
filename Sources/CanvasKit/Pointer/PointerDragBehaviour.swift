//
//  PointerDragBehaviour.swift
//  CanvasKit
//
//  Created by Dave Coleman on 14/1/2026.
//

import SwiftUI

/// Defines the drag interaction mode applied by `PointerDragModifier`.
public enum PointerDragBehaviour: Equatable, Sendable {

  /// An anchored drag from the origin to the current pointer position.
  ///
  /// This produces ordered rectangle endpoints suitable for lasso or marquee
  /// selection. Whether CanvasKit also draws a visible rectangle is configured
  /// independently by ``PointerDragConfiguration/showsMarquee``.
  case marquee

  /// Frame-to-frame drag deltas, optionally constrained to an axis.
  case continuous(axes: Axis.Set = .both)
}

extension PointerDragBehaviour {

  public var name: String {
    switch self {
      case .marquee: "Marquee"
      case .continuous(let axes): "Continuous (\(axes))"
    }
  }

  public var isMarquee: Bool {
    if case .marquee = self { return true }
    return false
  }
}

extension Axis.Set {
  public static var both: Axis.Set { [.horizontal, .vertical] }
}
