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
  var pointer: PointerState<ViewportSpace> = .init()

  /// Only updated when `processedTransform()` is called
  package var interactionContext: InteractionContext?

  var artworkFrame: Rect<ViewportSpace>?
  var currentTransform: TransformState = .identity

  init(toolConfiguration: ToolConfiguration = .default) {
    self.toolHandler = .init(configuration: toolConfiguration)
  }
}

extension CanvasHandler {

  /// Entry point for all raw input events from gesture modifiers.
  ///
  /// 1. Global gestures (swipe, pinch, hover) are handled centrally here.
  /// Tools never see these events.
  ///
  /// Pointer interactions (tap, drag) are forwarded to the effective tool's
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
    //    currentTransform: TransformState,
  ) -> TransformState? {

    let context = InteractionContext(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
    )
    self.interactionContext = context

    let resolver = CanvasInputResolver(
      context: context,
      effectiveTool: effectiveTool,
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

  var activeInteraction: ActiveInteraction {
    guard let interactionContext else { return .none }
    return .init(
      kind: interactionContext.interaction.kind,
      phase: interactionContext.phase,
    )
  }

  /// The runtime tool used to resolve canvas input right now.
  ///
  /// This includes transient overrides such as Space-held Pan. For the
  /// committed/base selection only, use `toolHandler.committedTool`.
  var effectiveTool: any CanvasTool { toolHandler.effectiveTool }

  @available(*, deprecated, renamed: "effectiveTool")
  var activeTool: (any CanvasTool)? { effectiveTool }

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
    return effectiveTool.resolvePointerStyle(context: interactionContext)
  }

}
