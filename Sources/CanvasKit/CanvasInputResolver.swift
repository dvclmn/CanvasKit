//
//  CanvasInputResolver.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/4/2026.
//

private import CoreTools
import SwiftUI

/// Centralises input resolution for `CanvasHandler`.
struct CanvasInputResolver {
  let context: InteractionContext
  let effectiveTool: (any CanvasTool)?
  let transform: TransformState
}

extension CanvasInputResolver {

  func resolve() -> InteractionAdjustment? {
    if let tool = effectiveTool,
      let toolContext = resolvedToolContext(for: tool)
    {
      let resolution = tool.resolveInteraction(
        context: toolContext,
        currentTransform: transform,
      )

      switch resolution {
        case .handled(let adjustment):
          return adjustment

        case .passthrough:
          break  // fall through to canvas defaults below
      }
    }

    // If not, fall back to defaults, which ensures that basics like
    // Swipe to pan, Pinch to Zoom etc work as expected.
    return Self.defaultResolution(
      for: context,
      currentTransform: transform,
    )
  }

  func resolvedContext() -> InteractionContext {
    guard context.matchedCapability == nil else { return context }
    guard let effectiveTool,
      let capability = effectiveTool.inputCapabilities.bestMatch(for: context)
    else { return context }

    return context.matching(capability)
  }

  private func resolvedToolContext(
    for tool: any CanvasTool
  ) -> InteractionContext? {
    if context.matchedCapability != nil {
      return context
    }

    guard let capability = tool.inputCapabilities.bestMatch(for: context) else {
      return nil
    }
    return context.matching(capability)
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

      case .hover:
        // Hover location is recorded globally by CanvasHandler so public
        // observation is independent of the effective tool. Returning no
        // adjustment here still allows a capable tool to claim hover above.
        return .none

      case .tap, .drag:
        // No tool claimed these — no default behaviour for pointer events.
        return nil
    }
  }

}
