//
//  CanvasInputResolver.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 2/4/2026.
//

import GeometryPrimitives
import InputPrimitives
import SwiftUI

/// Centralises input resolution for `CanvasHandler`.
struct CanvasInputResolver {
  let context: InteractionContext
  let activeTool: (any CanvasTool)?
  let transform: TransformState
}

extension CanvasInputResolver {

  func resolve() -> InteractionAdjustment? {

    /// 1. Does the active tool declare a matching capability?
    if let tool = activeTool,
      tool.inputCapabilities.contains(where: { $0.matches(context) })
    {

      let resolution = tool.resolveInteraction(
        context: context,
        currentTransform: transform,
      )

      switch resolution {
        case .handled(let adjustment):
          return adjustment
        //          return .tool(adjustment)

        case .passthrough:
          break  // fall through to canvas defaults below
      }
    }

    /// If not, fall back to defaults, which ensures that basics like
    /// Swipe to pan, Pinch to Zoom etc work as expected.
    return Self.defaultResolution(
      for: context,
      currentTransform: transform,
    )
  }

  var pointerStyle: PointerStyleCompatible? {
    activeTool?.resolvePointerStyle(context: context)
  }
}

// MARK: - Base Adjustment (Tool Use inactive)
extension CanvasInputResolver {

  static func defaultResolution(
    for context: InteractionContext,
    currentTransform: TransformState,
  ) -> InteractionAdjustment? {
    switch context.interaction {
      case .swipe(let delta):
        return .transform(.panAdjustment(for: currentTransform, delta: delta))
      //        return .transform(.translation(delta))
      //        return .base(.translation(delta))

      case .pinch(let scale):
        return .transform(.zoomAdjustment(for: currentTransform, by: scale))
      //        return .transform(.scale(scale))
      //        return .base(.scale(scale))

      case .rotation(let angle):
        return .transform(.rotation(angle))
      //        return .base(.rotation(angle))

      case .tap, .drag, .hover:
        // No tool claimed these — no default behaviour for pointer events.
        return nil
    }
  }

  /// Optional because not all transform adjustments are able to
  /// be created by all Interaction kinds
  //  private var baseAdjustment: TransformAdjustment? {
  //    switch context.interaction {
  //      case .swipe(let delta): return swipeAdjustment(delta: delta)
  //      case .pinch(let scale): return .scale(scale)
  //      case .rotation(let angle): return .rotation(angle)
  //      case .tap, .drag, .hover:
  //        print(
  //          "Interaction of type \"\(context.interaction.kind.displayName)\" invalid for Base transform. Tap, Drag and Hover Interactions are typically not used unless CanvasTool use is active."
  //        )
  //        return nil
  //    }
  //  }

  private func swipeAdjustment(delta: Size<ScreenSpace>) -> TransformAdjustment {

    /// If Option is held during a Swipe, it is interpreted as Zoom, not Pan
    guard context.modifiers.contains(.option) else {
      let newTranslation = transform.translation + delta
      return .translation(newTranslation)
    }

    /// Each point contributes up to 0.5% zoom change at sensitivity = 1.0
    let factor = ZoomComputation.factorFromDelta(
      CGSize(width: 0, height: delta.cgSize.height),
      weights: .vertical,
    )
    return .zoomAdjustment(for: transform, by: factor)
  }
}
