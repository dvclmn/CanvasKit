//
//  CanvasClipping.swift
//  CanvasKit
//
//  Created by Dave Coleman on 6/8/2026.
//

import Foundation

/// Describes how canvas artwork should be displayed outside the canvas bounds.
public enum CanvasClipping: Hashable, Codable, Sendable {

  /// Clip artwork to the rounded canvas rect.
  case clipped

  /// Reduce the opacity of artwork outside the rounded canvas rect by the
  /// supplied amount.
  ///
  /// Values are clamped to `0...1`; `NaN` resolves to `0`.
  /// `0` behaves like `none` and `1` behaves like `clipped`.
  case dimmed(CGFloat)

  /// Allow artwork to render outside the rounded canvas rect.
  case none
}

extension CanvasClipping {

  public func displayString(showsDimmingValue: Bool = true) -> String {
    switch self {
      case .clipped: "Clipped"
      case .dimmed(let amount):
        if showsDimmingValue {
          "Dimmed(\(amount.displayString(.concise)))"

        } else {
          "Dimmed"
        }
      case .none: "None"
    }
  }
}

extension CanvasClipping {
  static func normaliseDimmingAmount(_ amount: Double) -> Double {
    guard !amount.isNaN else { return 0 }
    
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
    displayString(showsDimmingValue: true)
  }
}
