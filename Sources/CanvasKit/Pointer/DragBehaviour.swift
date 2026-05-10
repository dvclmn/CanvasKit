//
//  PointerDragBehaviour.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 14/1/2026.
//

import SwiftUI

public struct PointerDragConfiguration: Sendable {
  let behaviour: PointerDragBehaviour
  let minimumDistance: CGFloat

  public init(
    behaviour: PointerDragBehaviour = .marquee,
    minimumDistance: CGFloat = 5,
  ) {
    self.behaviour = behaviour
    self.minimumDistance = minimumDistance
  }
}

extension PointerDragConfiguration {
  public static let marquee: Self = .init(behaviour: .marquee)
  public static let continuous: Self = .init(behaviour: .continuous(axes: .both))
}

/// Defines the drag interaction mode applied by `PointerDragModifier`.
public enum PointerDragBehaviour: Equatable, Sendable {

  /// A transient selection rectangle drawn from the drag origin to the current
  /// pointer position. All state is cleared on drag end.
  ///
  /// Typical use: lasso/marquee selection over a canvas or list.
  case marquee

  /// An accumulated offset that persists across drag gestures.
  ///
  /// Each new drag begins from the offset committed by the previous drag, so
  /// movement compounds over time. Pass a `GeometryAxis/Set` to lock to an axis.
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
