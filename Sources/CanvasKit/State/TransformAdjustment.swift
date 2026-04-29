//
//  TransformAdjustment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 8/4/2026.
//

import GeometryPrimitives
import SwiftUI

/// Previously held by `CanvasAdjustment`
///
/// `TransformAdjustment` is distinct from `PointerAdjustment`.
/// A transform adjustment can come from either a pointer or a gesture interaction.
///
/// E.g. a pointer drag can express a zoom in/out, thus adjusting transform's scale.
///
/// This enum corresponds to `TransformState`. Useful for expressing
/// a *single* adjustment, rather than all three.
///
/// Important: Property names `translation`, `scale` and `rotation`
/// are intentionally generic, to discourage direct association with e.g. pan/zoom/rotate.
/// Whilst the default usage for these is providing values to `offset`,
/// `scaleEffect` and `rotationEffect` SwiftUI modifiers, that is not
/// the only way they can be used. These transformations
/// can be applied in a range of other scenarios, such as
///
// TODO: List more examples for above
// I'm thinking of the different ways gestures can be used
public enum TransformAdjustment: Sendable {
  case translation(Size<ScreenSpace>)
  case scale(Double)
  case rotation(Angle)
}

extension TransformAdjustment {
  
  /// Certain Transform adjustments can only be mutated by
  /// compatible interactions.
  ///
  /// UPDATE: I think this may limit how tools may wish to declare
  /// some capacibilities? Have turned off for now.
//  var supportedInteractions: InteractionKind.Set {
//    switch self {
//      case .translation: [.swipe, .drag]
//      case .scale: [.swipe, .pinch, .tap, .drag]
//      case .rotation: [.swipe, .rotate, .drag]
//    }
//  }
}

extension TransformAdjustment {
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
    delta: Size<ScreenSpace>,
  ) -> Self {
    let new = transform.translation + delta
    return .translation(new)
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
