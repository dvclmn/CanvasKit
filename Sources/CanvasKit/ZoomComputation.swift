//
//  ZoomComputation.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 19/3/2026.
//

import SwiftUI

/// Shared utilities for mapping pointer deltas to multiplicative zoom factors.
///
/// The mapping uses a user-facing sensitivity on a 0...1 scale:
/// - 0 = not sensitive,
/// - 1 = highly sensitive.
///
/// The factor is computed as:
/// factor = 1 + contribution * perPoint
/// where perPoint = sensitivity * maxPerPoint.
///
/// Choose weights to control how horizontal and vertical movement contribute:
/// - `.upRight`: right (+x) and up (-y) increase zoom; left and down decrease.
/// - `.vertical`: down (+y) increases zoom; up decreases (matches existing swipe behaviour).
public enum ZoomComputation: Sendable {

  public struct Weights: Sendable {
    let x: CGFloat
    let y: CGFloat

    /// Right (+x) and up (-y) increase zoom.
    public static let upRight = Weights(x: 1, y: -1)
    /// Vertical-only: down (+y) increases zoom, up decreases.
    public static let vertical = Weights(x: 0, y: 1)
  }

  /// Compute a multiplicative zoom factor from a delta in points.
  /// - Parameters:
  ///   - delta: A CGSize delta in screen space.
  ///   - weights: Axis contribution weights.
  ///   - sensitivity: User-facing sensitivity from 0 (not sensitive) to 1 (highly sensitive).
  ///   - maxPerPoint: Maximum per-point zoom factor contribution.
  ///   - minFactor: Lower bound to keep factor positive.
  /// - Returns: A positive factor suitable for multiplicative scaling.
  public static func factorFromDelta(
    _ delta: CGSize,
    weights: Weights = .upRight,
    sensitivity: CGFloat = 1.0,
    maxPerPoint: CGFloat = 0.005,
    minFactor: CGFloat = 0.1,
  ) -> CGFloat {
    let contribution = (delta.width * weights.x) + (delta.height * weights.y)
    
    /// Clamp user-facing sensitivity to 0...1, then scale by maxPerPoint to get per-point gain
    let clamped = max(0, min(1, sensitivity))
    let perPoint = clamped * maxPerPoint
    let raw = 1.0 + (contribution * perPoint)
    return max(raw, minFactor)
  }

  /// Compute a multiplicative zoom factor from two points (from → to).
  public static func factorFromPoints(
    from: CGPoint,
    to: CGPoint,
    weights: Weights = .upRight,
    sensitivity: CGFloat = 1.0,
    maxPerPoint: CGFloat = 0.005,
    minFactor: CGFloat = 0.1,
  ) -> CGFloat {
    let delta = CGSize(width: to.x - from.x, height: to.y - from.y)
    return factorFromDelta(
      delta,
      weights: weights,
      sensitivity: sensitivity,
      maxPerPoint: maxPerPoint,
      minFactor: minFactor,
    )
  }
}
