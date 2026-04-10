//
//  TransformAdjustment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 8/4/2026.
//

import SwiftUI
import InteractionKit

//struct TransformOperation {
//  let adjustment: TransformAdjustment
//  let interaction: Interaction
//
//  var isValidInteraction: Bool {
//
//  }
//}

/// Previously held by `CanvasAdjustment`
/// Considering rename to `TransformAdjustment`
///
/// This is distinct from Pointer, because a `TransformAdjustment`
/// can come from *both* a Pointer and a Gesture.
///
/// Modeled here as an enum alongside existing `TransformState`,
/// as this is part of the Tool resolution pipeline, which needs to be able
/// to express a single Transform, not all three at once.
///
/// Important: Default application for these is for the `offset`,
/// `scaleEffect` and `rotationEffect` modifiers
/// on the Canvas artwork View. *However*, these transformations
/// can be applied in a range of other scenarios, such as
// TODO: List more examples for above
public enum TransformAdjustment: Sendable {
  case translation(Size<ScreenSpace>)
  case scale(Double)
  case rotation(Angle)
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

  public var supportedInteractions: InteractionKinds {
    switch self {

      /// Swipe is the default. Drag is typically via e.g. a Pan Tool
      case .translation: [.swipe, .drag]

      ///
      case .scale: []
      case .rotation: []
    }
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
