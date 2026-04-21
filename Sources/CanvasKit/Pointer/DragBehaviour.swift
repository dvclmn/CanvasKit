//
//  PointerDragBehaviour.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 14/1/2026.
//

import CanvasCore
import SwiftUI

/// Defines the drag interaction mode applied by `PointerDragModifier`.
public enum PointerDragBehaviour: Equatable, Sendable {
//public enum PointerDragBehaviour: Equatable, Sendable {

  /// A transient selection rectangle drawn from the drag origin to the current
  /// pointer position. All state is cleared on drag end.
  ///
  /// Typical use: lasso/marquee selection over a canvas or list.
  case marquee

  /// An accumulated offset that persists across drag gestures.
  ///
  /// Each new drag begins from the offset committed by the previous drag, so
  /// movement compounds over time. Pass a `GeometryAxis/Set` to lock to an axis.
  case continuous(axes: GeometryAxis.Set)

  /// Drag gesture is inactive; no callbacks or state changes are produced.
  case none

  /// Convenience for `.continuous(axes: .all)`.
  public static var continuous: Self { .continuous(axes: .all) }
}

extension PointerDragBehaviour {

  public var name: String {
    switch self {
      case .marquee: "Marquee"
      case .continuous(let axes): "Continuous (\(axes))"
      case .none: "None"
    }
  }

  /// The axis constraint for continuous drags. Only applicable for
  /// `continuous`, returns `.all` for other modes
  public var axes: GeometryAxis.Set {
    if case .continuous(let axes) = self { return axes }
    return .all
  }

  public var isMarquee: Bool {
    if case .marquee = self { return true }
    return false
  }

  /// Whether drag gestures are permitted.
  public var isEnabled: Bool { self != .none }
}

extension Axis.Set {
  static var all: Axis.Set { [.horizontal, .vertical] }
}
