//
//  CanvasHandler.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import GeometryPrimitives
import InputPrimitives
import SwiftUI

@Observable
final class CanvasHandler {

  var toolHandler: ToolHandler
  var pointer: PointerState = .initial

  /// Only updated when `processedTransform()` is called
  package var interactionContext: InteractionContext?

  var artworkFrame: Rect<ScreenSpace>?

  init(toolConfiguration: ToolConfiguration = .default) {
    self.toolHandler = .init(configuration: toolConfiguration)
  }
}

extension CanvasHandler {

  var activeTool: (any CanvasTool)? { toolHandler.effectiveTool }

  /// Entry point for all raw input events from gesture modifiers.
  ///
  /// 1. Global gestures (swipe, pinch, hover) are handled centrally here.
  /// Tools never see these events.
  ///
  /// Pointer interactions (tap, drag) are forwarded to the active tool's
  /// `resolvePointerInteraction()` method when the tool claims that
  /// interaction/adjustment pair via `inputCapabilities`.
  ///
  /// Returns an optional to allow a no-op in ``InteractionModifiers``,
  /// so that interaction modifiers that don't need to touch Transform state
  /// don't inadvertantly write it to `identity`.
  //  func handleInteraction(
  func processedTransform(
    _ interaction: Interaction,
    phase: InteractionPhase,
    modifiers: Modifiers,
    currentTransform: TransformState,
  ) -> TransformState? {

    let context = InteractionContext(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
    )
    self.interactionContext = context

    let resolver = CanvasInputResolver(
      context: context,
      activeTool: activeTool,
      transform: currentTransform,
    )

    guard let resolvedAdjustment = resolver.resolve() else {
      print("No resolution for provided interaction context: \(context)")
      return nil
    }

    return handleAdjustment(
      resolvedAdjustment,
      transform: currentTransform,
    )
  }
}

extension CanvasHandler {

  private func handleAdjustment(
    _ adjustment: InteractionAdjustment,
    transform: TransformState,
  ) -> TransformState {
    switch adjustment {
      case .transform(let adj):
        return adj.updatedState(transform)

      case .pointer(let adj):
        switch adj {
          case .tap(let point): self.pointer.tap = point
          case .drag(let rect): self.pointer.drag = rect
          case .hover(let point): self.pointer.hover = point
        }
        return transform

      case .none: return transform
    }
  }
}

extension CanvasHandler {
  func updateModifiers(_ modifiers: Modifiers) {
    toolHandler.updateModifiers(modifiers)
    interactionContext = interactionContext?.withModifiers(modifiers)
  }

  // TODO: Change how interactionContext is updated, as this pointer style
  // is possibly not being updated at the right cadence. interactionContext
  // is currently only updated when processedTransform() is run.
  var pointerStyle: PointerStyleCompatible? {
    guard let interactionContext else { return nil }
    return activeTool?.resolvePointerStyle(context: interactionContext)
  }

}
