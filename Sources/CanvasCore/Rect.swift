//
//  Rect.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 3/3/2026.
//

import Foundation

/// Allows differentiating one `CGRect` from another, to make it clearer
/// and easier to move between different coordinate spaces, with compile-time safety.
public struct Rect<Space>: Sendable, Equatable {

  public var x: CGFloat
  public var y: CGFloat
  public var width: CGFloat
  public var height: CGFloat

  public init(
    x: CGFloat,
    y: CGFloat,
    width: CGFloat,
    height: CGFloat
  ) {
    self.x = x
    self.y = y
    self.width = width
    self.height = height
  }
}

extension Rect {

  public init(origin: Point<Space>, size: Size<Space>) {
    self.x = origin.x
    self.y = origin.y
    self.width = size.width
    self.height = size.height
  }

  /// Creates a rect from two corner points, normalising so origin is the min corner.
  public init(from a: Point<Space>, to b: Point<Space>) {
    let minX = min(a.x, b.x)
    let minY = min(a.y, b.y)
    let maxX = max(a.x, b.x)
    let maxY = max(a.y, b.y)
    self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
  }

  public init(fromRect cgRect: CGRect) {
    self.x = cgRect.origin.x
    self.y = cgRect.origin.y
    self.width = cgRect.size.width
    self.height = cgRect.size.height
  }

  public var cgRect: CGRect { .init(x: x, y: y, width: width, height: height) }

  public var origin: Point<Space> { .init(x: x, y: y) }
  public var size: Size<Space> { .init(width: width, height: height) }
  public static var zero: Self { .init(origin: .zero, size: .zero) }

  public var midpoint: Point<Space> {
    .init(
      x: origin.x + size.width / 2,
      y: origin.y + size.height / 2
    )
  }

  public var minX: CGFloat { x }
  public var minY: CGFloat { y }
  public var maxX: CGFloat { x + width }
  public var maxY: CGFloat { y + height }
  public var midX: CGFloat { x + width / 2 }
  public var midY: CGFloat { y + height / 2 }
}

extension CGRect {
  public var screenRect: Rect<ScreenSpace> { .init(fromRect: self) }
}
