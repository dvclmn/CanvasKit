//
//  PointerState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 7/3/2026.
//

import CoreGraphics
//import InteractionKit



/// Raw locations/geometry in screen space, no
/// coordinate space mapping applied
public struct PointerState<Space>: Sendable, Equatable {
  public var tap: Point<Space>?
  public var hover: Point<Space>?
  public var drag: Rect<Space>?

  public init(
    tap: Point<Space>? = nil,
    hover: Point<Space>? = nil,
    drag: Rect<Space>? = nil,
  ) {
    self.tap = tap
    self.hover = hover
    self.drag = drag
  }
}

//extension PointerState {
//  public static let initial = PointerState()
//}
