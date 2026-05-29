//
//  ZoomOperation.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/1/2026.
//

import Foundation

/// Describes a zoom command that can be resolved against a subject and viewport.
public enum ZoomOperation: Sendable {
  case identity
  case zoom(CGFloat)
  case fit
  case fill
}

extension ZoomOperation {

  /// Resolves the command to a concrete scale value.
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
