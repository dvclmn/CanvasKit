//
//  ZoomOperation.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/1/2026.
//

import Foundation

/// Describes a zoom command that can be resolved against a canvas and viewport.
public enum ZoomOperation: Sendable {
  case identity
  case zoom(CGFloat)
  case fit
  case fill
}

extension ZoomOperation {

  /// Resolves this operation to a validated scale for a canvas in a viewport.
  ///
  /// `padding` is an inset on every edge of the viewport. CanvasKit does not
  /// choose a visual inset: callers provide the padding that matches their UI.
  ///
  /// - Returns: A finite, positive scale, or `nil` when either size, the
  ///   padding, or the resulting available viewport is invalid.
  public func resolvedScale(
    canvasSize: Size<CanvasSpace>,
    in viewportSize: Size<ViewportSpace>,
    padding: CGFloat = 0,
  ) -> Double? {
    guard canvasSize.isFiniteAndPositive,
      viewportSize.isFiniteAndPositive,
      padding.isFinite,
      padding >= 0
    else { return nil }

    switch self {
      case .identity:
        return 1

      case .zoom(let scale):
        guard scale.isFinite, scale > 0 else { return nil }
        return Double(scale)

      case .fit, .fill:
        let availableWidth = viewportSize.width - (padding * 2)
        let availableHeight = viewportSize.height - (padding * 2)
        guard availableWidth.isFinite,
          availableHeight.isFinite,
          availableWidth > 0,
          availableHeight > 0
        else { return nil }

        let horizontalScale = Double(availableWidth / canvasSize.width)
        let verticalScale = Double(availableHeight / canvasSize.height)
        guard horizontalScale.isFinite,
          verticalScale.isFinite,
          horizontalScale > 0,
          verticalScale > 0
        else { return nil }

        switch self {
          case .fit: return min(horizontalScale, verticalScale)
          case .fill: return max(horizontalScale, verticalScale)
          case .identity, .zoom: fatalError("Handled above")
        }
    }
  }

  /// Resolves the command to a concrete scale value.
  ///
  /// Prefer ``resolvedScale(canvasSize:in:padding:)`` for new code. This
  /// legacy raw-size API preserves its existing 40-point default padding.
  public func resolve(
    subject: CGSize,
    viewport: CGSize
  ) -> CGFloat {
    switch self {
      case .identity: return .zero
      case .zoom(let level): return level

      case .fit:
        let values = Self.scaleValues(
          artwork: subject,
          viewport: viewport
        )
        return min(values.0, values.1)

      case .fill:
        let values = Self.scaleValues(
          artwork: subject,
          viewport: viewport
        )
        return max(values.0, values.1)
    }
  }

  public static func scaleValues(
    artwork: CGSize,
    viewport: CGSize,
    padding: CGFloat = 40
  ) -> (CGFloat, CGFloat) {

    // Calculate available space after padding.
    let viewportAvailable = CGSize(
      width: viewport.width - (padding * 2),
      height: viewport.height - (padding * 2)
    )
//    let viewportAvailable = viewport.adjustBoth { $0 - (padding * 2) }

    return (
      viewportAvailable.width / artwork.width,
      viewportAvailable.height / artwork.height
    )

  }
}

private extension Size {
  var isFiniteAndPositive: Bool {
    width.isFinite && height.isFinite && width > 0 && height > 0
  }
}
