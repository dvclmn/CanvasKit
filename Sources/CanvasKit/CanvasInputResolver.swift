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
        return .transform(
          .swipeAdjustment(
            for: currentTransform,
            delta: delta,
            modifiers: context.modifiers,
          )
        )

      case .pinch(let scale):
        return .transform(.scale(scale))

      case .rotation(let angle):
        return .transform(.rotation(angle))

      case .hover(let location):
        return .pointer(.hover(location))

      case .tap, .drag:
        // No tool claimed these — no default behaviour for pointer events.
        return nil
    }
  }

}
