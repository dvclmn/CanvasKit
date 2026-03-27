//
//  DragBehaviour.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 14/1/2026.
//

import SwiftUI

/// Defines the drag interaction mode applied by ``PointerDragModifier``.
///
/// - ``marquee``: A transient selection rectangle, cleared when the drag ends.
/// - ``continuous(axes:)``: An accumulated offset that persists across drags.
/// - ``none``: No drag response.
public enum DragBehavior: Equatable, Sendable, Hashable {

  /// A transient selection rectangle drawn from the drag origin to the current
  /// pointer position. All state is cleared on drag end.
  ///
  /// Typical use: lasso/marquee selection over a canvas or list.
  case marquee

  /// An accumulated offset that persists across drag gestures.
  ///
  /// Each new drag begins from the offset committed by the previous drag, so
  /// movement compounds over time. Pass a ``GridAxis/Set`` to lock to an axis.
  case continuous(axes: GridAxis.Set)

  /// Drag gesture is inactive; no callbacks or state changes are produced.
  case none

  /// Convenience for `.continuous(axes: .all)`.
  public static var continuous: Self { .continuous(axes: .all) }
}

extension DragBehavior {

  public var name: String {
    switch self {
      case .marquee: "Marquee"
      case .continuous(let axes): "Continuous (\(axes.name))"
      case .none: "None"
    }
  }

  /// The axis constraint for continuous drags. Returns `.all` for other modes.
  public var axes: GridAxis.Set {
    if case .continuous(let axes) = self { return axes }
    return .all
  }

  /// Whether this behavior renders a marquee selection overlay.
  public var isMarquee: Bool {
    if case .marquee = self { return true }
    return false
  }

  /// Whether drag gestures are permitted. `false` only for `.none`.
  public var isEnabled: Bool { self != .none }
}
