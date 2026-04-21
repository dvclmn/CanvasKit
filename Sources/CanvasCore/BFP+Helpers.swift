//
//  ZoomHelpers.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//

import Foundation

/// NOTE: These are duplicated from BasePrimitives (to avoid too many dependancies)
extension BinaryFloatingPoint {
  func removingZoom(
    _ zoom: Self,
    across range: ClosedRange<Self>? = nil,
    sensitivity: Self? = nil,
  ) -> Self {
    guard zoom.isGreaterThanZero, range?.isGreaterThanZero ?? false else {
      return self
    }
    let effectiveZoom = range.map { zoom.clamped(to: $0) } ?? zoom

    if let sensitivity {
      let s = sensitivity.clamped(to: 0...1)
      return self * Self(pow(Double(effectiveZoom), Double(s - 1)))
    }

    return self / effectiveZoom
  }

  var isGreaterThanZero: Bool { self > 0 }
  package var isFiniteAndGreaterThanZero: Bool { isFinite && self > 0 }
}

extension ClosedRange {
  var isGreaterThanZero: Bool { lowerBound < upperBound }
}

extension Comparable {

  /// Returns `self` clamped to the provided range.
  /// Note to self: This is *not* the same as normalising.
  /// For normalisation see `BFP+Normalise`
  @inline(__always)
  package func clamped(to range: ClosedRange<Self>) -> Self {
    return clamped(range.lowerBound, range.upperBound)
  }

  /// `min` == `lowerBound`
  /// `max` == `upperBound`
  @inline(__always)
  func clamped(_ lower: Self, _ upper: Self) -> Self {
    guard lower < upper else { return self }
    return Swift.min(upper, Swift.max(lower, self))
  }
}
