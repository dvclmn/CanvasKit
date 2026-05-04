//
//  PointerState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 7/3/2026.
//

import CoreGraphics
//import InteractionKit

import GeometryPrimitives

/// Raw locations/geometry in screen space, no
/// coordinate space mapping applied
public struct PointerState: Sendable, Equatable {
  public var tap: Point<ViewportSpace>?
  public var hover: Point<ViewportSpace>?
  public var drag: Rect<ViewportSpace>?

  public init(
    tap: Point<ViewportSpace>? = nil,
    hover: Point<ViewportSpace>? = nil,
    drag: Rect<ViewportSpace>? = nil,
  ) {
    self.tap = tap
    self.hover = hover
    self.drag = drag
  }
}

extension PointerState {
  public static let initial = PointerState()
}
