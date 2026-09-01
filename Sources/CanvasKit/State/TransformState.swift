//
//  CanvasTransformState.swift
//  CanvasKit
//
//  Created by Dave Coleman on 1/3/2026.
//

import SwiftUI

public struct TransformState: Sendable, Equatable {
  public var translation: Size<ViewportSpace>

  /// This value is not clamped. Should be done by the caller if required
  public var scale: Double
  public var rotation: Angle

  public init(
    translation: Size<ViewportSpace> = .zero,
    scale: Double = 1.0,
    rotation: Angle = .zero,
  ) {
    self.translation = translation
    self.scale = scale
    self.rotation = rotation
  }

  public static var identity: Self { .init() }
}

extension TransformState {
  public mutating func reset() { self = Self.identity }

  /// Resolves a programmatic zoom operation into a reset transform.
  ///
  /// The result deliberately has zero translation and rotation. It is suited
  /// to explicit commands such as Fit to View, not to incrementally changing
  /// the scale of an existing transform.
  ///
  /// The caller owns when to apply the result and supplies its zoom-range and
  /// padding policy.
  public static func resolved(
    _ operation: ZoomOperation,
    canvasSize: Size<CanvasSpace>,
    in viewportSize: Size<ViewportSpace>,
    padding: CGFloat = 0,
    zoomRange: ClosedRange<Double>,
  ) -> Self? {
    guard zoomRange.lowerBound.isFinite,
      zoomRange.upperBound.isFinite,
      zoomRange.lowerBound > 0,
      zoomRange.lowerBound <= zoomRange.upperBound,
      let scale = operation.resolvedScale(
        canvasSize: canvasSize,
        in: viewportSize,
        padding: padding,
      )
    else { return nil }

    return .init(scale: min(max(scale, zoomRange.lowerBound), zoomRange.upperBound))
  }

  /// Resolves a fit-to-view transform with zero translation and rotation.
  ///
  /// This convenience wrapper is equivalent to calling
  /// ``resolved(_:canvasSize:in:padding:zoomRange:)`` with ``ZoomOperation/fit``.
  public static func fitted(
    canvasSize: Size<CanvasSpace>,
    in viewportSize: Size<ViewportSpace>,
    padding: CGFloat = 0,
    zoomRange: ClosedRange<Double>,
  ) -> Self? {
    resolved(
      .fit,
      canvasSize: canvasSize,
      in: viewportSize,
      padding: padding,
      zoomRange: zoomRange,
    )
  }
}

extension TransformState: CustomStringConvertible {
  public var description: String {
    """
    Translation: \(translation.cgSize)
    Scale: \(scale)
    Rotation (Degrees): \(rotation.degrees)
    """
  }
}
