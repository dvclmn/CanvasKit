//
//  CanvasClippingContainerValue.swift
//  CanvasKit
//
//  Created by Dave Coleman on 28/2/2026.
//

import SwiftUI

/// Describes how canvas artwork should be displayed outside the canvas bounds.
public enum CanvasClipping: Hashable, Codable, Sendable {

  /// Clip artwork to the rounded canvas rect.
  case clipped

  /// Reduce the opacity of artwork outside the rounded canvas rect by the
  /// supplied amount.
  ///
  /// Values are clamped to `0...1`. `0` behaves like `none`
  /// and `1` behaves like `clipped`.
  case dimmed(CGFloat)

  /// Allow artwork to render outside the rounded canvas rect.
  case none
}

extension View {
  /// Controls how this canvas layer is displayed outside the rounded canvas rect.
  @ViewBuilder
  public func canvasClipping(_ clipping: CanvasClipping) -> some View {
    if #available(macOS 15, iOS 18, *) {
      self.containerValue(\.canvasClipping, clipping)
    } else {
      self
    }
  }

  /// Controls whether this canvas layer is clipped to the rounded canvas rect.
  @available(*, deprecated, renamed: "canvasClipping(_:)")
  @ViewBuilder
  public func canvasClipped(_ enabled: Bool) -> some View {
    self.canvasClipping(enabled ? .clipped : .none)
  }
}

@available(macOS 15, iOS 18, *)
extension ContainerValues {
  @Entry var canvasClipping: CanvasClipping = .clipped
}

extension CanvasClipping {
  static func normaliseDimmingAmount(_ amount: Double) -> Double {
    guard amount.isFinite else {
      return amount.sign == .minus ? 0 : 1
    }

    return min(max(amount, 0), 1)
  }

  var normalisedDimmingAmount: Double {
    guard case .dimmed(let amount) = self else { return 0 }
    return Self.normaliseDimmingAmount(Double(amount))
  }

  var resolved: CanvasClipping {
    switch self {
      case .dimmed where normalisedDimmingAmount <= 0: .none
      case .dimmed where normalisedDimmingAmount >= 1: .clipped
      default: self
    }
  }
}

extension CanvasClipping: CustomStringConvertible {
  public var description: String {
    switch self {
      case .clipped: "Clipped"
      case .dimmed(let amount): "Dimmed(\(amount))"
      case .none: "No clipping"
    }
  }
}
