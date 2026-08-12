//
//  CanvasHandler.swift
//  CanvasKit
//
//  Created by Dave Coleman on 8/3/2026.
//

private import CoreTools
import SwiftUI

@Observable
final class CanvasHandler {

  var toolHandler: ToolHandler
  var pointer: PointerState<ViewportSpace> = .init()

  /// Complete context for the most recent interaction that carried enough
  /// detail to be resolved by the tool pipeline.
  var lastInteractionContext: InteractionContext?
  var latestInteraction: InteractionSnapshot = .none
  
  private var activeInteractionContexts: [Interaction.Kind: InteractionContext] = [:]

  var artworkFrame: Rect<ViewportSpace>?
  var currentTransform: TransformState = .identity

  var measuredCanvasSize: Size<CanvasSpace>?

  init(
    toolConfiguration: ToolConfiguration?,
    currentTransform: TransformState = .identity,
  ) {
    self.toolHandler = .init(configuration: toolConfiguration)
    self.currentTransform = currentTransform
  }
}

extension CanvasHandler {

  /// Entry point for all raw input events from gesture modifiers.
  ///
  /// 1. Global gestures (swipe, pinch, hover) are handled centrally here.
  /// Tools never see these events.
  ///
  /// Claimed interactions are forwarded to the effective tool's
  /// ``CanvasTool/resolveInteraction(context:currentTransform:)`` method.
  ///
  /// Returns an optional to allow a no-op in ``InteractionModifiers``,
  /// so that interaction modifiers that don't need to touch Transform state
  /// don't inadvertently write it to `identity`.
  //  func handleInteraction(
  func processedTransform(
    _ interaction: Interaction,
    phase: InteractionPhase,
    modifiers: EventModifiers,
  ) -> TransformState? {

    let context = InteractionContext(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
    )
    self.lastInteractionContext = context
    self.latestInteraction = .init(context: context)
    updateActiveInteraction(with: context)

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

  func endInteraction(
    _ kind: Interaction.Kind,
    phase: InteractionPhase,
    modifiers: EventModifiers,
  ) {
    latestInteraction = .init(kind: kind, phase: phase)
    activeInteractionContexts[kind] = nil

    if let context = lastInteractionContext,
      context.interaction.kind == kind
    {
      lastInteractionContext = context
        .withPhase(phase)
        .withModifiers(modifiers)
    }

    if kind == .hover {
      pointer.hover = nil
    }
  }

  private func updateActiveInteraction(with context: InteractionContext) {
    let kind = context.interaction.kind

    if context.phase.isActive {
      activeInteractionContexts[kind] = context
    } else {
      activeInteractionContexts[kind] = nil
    }
  }
}

extension CanvasHandler {

  func coordinateSpaceMapper(in size: Size<CanvasSpace>?) -> CoordinateSpaceMapper? {
    guard let artworkFrame,
      let resolvedSize = resolvedCanvasSize(for: size)
    else { return nil }
    return .init(frame: artworkFrame, canvasSize: resolvedSize)
  }

  func resolvedCanvasSize(for size: Size<CanvasSpace>?) -> Size<CanvasSpace>? {
    size ?? measuredCanvasSize
  }

  var activeInteraction: ActiveInteraction {
    guard !activeInteractionContexts.isEmpty else { return .none }
    return .init(contextsByKind: activeInteractionContexts)
  }

  /// The runtime tool used to resolve canvas input right now.
  ///
  /// This includes transient overrides such as Space-held Pan. For the
  /// committed/base selection only, use `toolHandler.committedTool`.
  var effectiveTool: any CanvasTool { toolHandler.effectiveTool }

}

extension CanvasHandler {
  func updateModifiers(_ modifiers: EventModifiers) {
    toolHandler.updateModifiers(modifiers)
    lastInteractionContext = lastInteractionContext?.withModifiers(modifiers)
    activeInteractionContexts = activeInteractionContexts.mapValues { context in
      context.withModifiers(modifiers)
    }
  }

  // TODO: Change how interactionContext is updated, as this pointer style
  // is possibly not being updated at the right cadence. interactionContext
  // is currently only updated when processedTransform() is run.
  var pointerStyle: CanvasPointerStyle? {
    guard let lastInteractionContext else { return nil }
    return effectiveTool.resolvePointerStyle(context: lastInteractionContext)
  }

}
