//
//  ZoomOperation.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 9/1/2026.
//

import Foundation

/// Note: This previously had associated values for fit/fill to provide
/// geometry info, needed to actually calculate what fit/fill looks like.
/// Not sure whether this should come back, or be handled elsewhere
public enum ZoomOperation: Sendable {
  case identity  // 100% / no zoom
  case zoom(CGFloat)
  case fit
  case fill
}

extension ZoomOperation {

  /// ```
  /// state = adjustment
  ///   .resolve(current: state, artwork: artwork, viewport: viewport)
  ///   .clamped()
  ///   .withPhase(.active)
  ///
  ///   ```
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

    /// Calculate available space after padding
    let viewportAvailable = viewport.adjustBoth { $0 - (padding * 2) }

    return (
      viewportAvailable.width / artwork.width,
      viewportAvailable.height / artwork.height
    )

  }
}
