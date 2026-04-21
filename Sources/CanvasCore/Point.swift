//
//  Point.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 3/3/2026.
//

import Foundation

/// Allows differentiating one `CGPoint` from another, to make it clearer
/// and easier to move between different coordinate spaces, with compile-time safety.
///
/// E.g.

/// ```
/// enum ScreenSpace {}
/// enum CanvasSpace {}
///
/// func drawHandle(at point: Point<ScreenSpace>) { ... }
/// let canvasPoint: Point<CanvasSpace> = .init(x: 120, y: 80)
///
/// ```
///
/// Compile error – wrong space:
/// `drawHandle(at: canvasPoint)`
///
/// Make the conversion explicit via the mapping:
///
/// ```
/// let mapping: ViewportMapping = ... // produced from geometry + transform
/// let screenPoint = mapping.toGlobal(point: canvasPoint.cgPoint) // or a space-aware overload
/// drawHandle(at: Point<ScreenSpace>(fromPoint: screenPoint))
/// ```
public struct Point<Space>: Sendable, Equatable {
  public var x: CGFloat
  public var y: CGFloat

  public init(x: CGFloat, y: CGFloat) {
    self.x = x
    self.y = y
  }

  public init(fromPoint point: CGPoint) {
    self.x = point.x
    self.y = point.y
  }

  public init(fromOffset point: CGSize) {
    self.x = point.width
    self.y = point.height
  }
}

extension Point {
  public var cgPoint: CGPoint { .init(x: x, y: y) }
  public static var zero: Self { .init(x: 0, y: 0) }
}

extension CGPoint {
  public var screenPoint: Point<ScreenSpace> { .init(fromPoint: self) }
}

// MARK: - Arithmetic

/// Subtracting two points in the same space yields a size (displacement vector).
//public func - <Space>(
//  lhs: Point<Space>,
//  rhs: Point<Space>
//) -> Size<Space> {
//  Size(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
//}
