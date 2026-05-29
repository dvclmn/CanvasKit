//
//  TransformAdjustment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 8/4/2026.
//

import CoreTools
import SwiftUI
import ViewTools

/// A single change to one part of ``TransformState``.
///
/// Transform adjustments are intentionally phrased as translation, scale, and
/// rotation rather than pan, zoom, and rotate so they can be produced by
/// gestures, pointer tools, or app-defined input.
public enum TransformAdjustment: Sendable {
  case translation(Size<ViewportSpace>)
  case scale(Double)
  case rotation(Angle)
}

extension TransformAdjustment {

  // Potential future validation: restrict transform adjustments to compatible
  // interaction kinds once tool capabilities have settled.
  //  var supportedInteractions: InteractionKind.Set {
  //    switch self {
  //      case .translation: [.swipe, .drag]
  //      case .scale: [.swipe, .pinch, .tap, .drag]
  //      case .rotation: [.swipe, .rotate, .drag]
  //    }
  //  }
}

extension TransformAdjustment {

  /// Creates a new state, based on the transform property that changed
  public func updatedState(_ current: TransformState) -> TransformState {
    var new = current
    switch self {
      case .translation(let val): new.translation = val
      case .scale(let val): new.scale = val
      case .rotation(let val): new.rotation = val
    }
    return new
  }

  public static func zoomAdjustment(
    for transform: TransformState,
    by factor: CGFloat,
  ) -> Self {
    let new = transform.scale * factor
    return .scale(new)
  }

  public static func panAdjustment(
    for transform: TransformState,
    delta: Size<ViewportSpace>,
  ) -> Self {
    let new = transform.translation + delta
    return .translation(new)
  }

  static func swipeAdjustment(
    for transform: TransformState,
    delta: Size<ViewportSpace>,
    modifiers: EventModifiers,
  ) -> TransformAdjustment {

    // If Option is held during a swipe, it is interpreted as zoom, not pan.
    guard modifiers.contains(.option) else {
      return .panAdjustment(for: transform, delta: delta)
    }

    // Each point contributes up to 0.5% zoom change at sensitivity = 1.0.
    let factor = ZoomComputation.factorFromDelta(
      CGSize(width: 0, height: delta.cgSize.height),
      weights: .vertical,
    )
    return .zoomAdjustment(for: transform, by: factor)
  }
}

extension TransformAdjustment: CustomStringConvertible {
  public var description: String {
    switch self {
      case .translation(let size): "Translation: \(size)"
      case .scale(let double): "Scale: \(double)"
      case .rotation(let angle): "Rotation: \(angle)"
    }
  }
}
