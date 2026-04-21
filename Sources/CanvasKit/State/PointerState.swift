//
//  PointerState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 7/3/2026.
//

import CoreGraphics
//import InteractionKit
//import CanvasCore
import GeometryPrimitives

/// Raw locations/geometry in screen space, no
/// coordinate space mapping applied
public struct PointerState: Sendable, Equatable {
  public var tap: Point<ScreenSpace>?
  public var hover: Point<ScreenSpace>?
  public var drag: Rect<ScreenSpace>?

  public init(
    tap: Point<ScreenSpace>? = nil,
    hover: Point<ScreenSpace>? = nil,
    drag: Rect<ScreenSpace>? = nil,
  ) {
    self.tap = tap
    self.hover = hover
    self.drag = drag
  }
}

extension PointerState {
  public static let initial = PointerState()
}
