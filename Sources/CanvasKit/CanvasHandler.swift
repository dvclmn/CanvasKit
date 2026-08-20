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
//  var pointerDragEvent: PointerDragSnapshot<ViewportSpace>?

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
    toolSelection: ToolSelection? = nil,
    currentTransform: TransformState = .identity,
  ) {
    self.toolHandler = .init(
      configuration: toolConfiguration,
      selection: toolSelection,
    )
    self.currentTransform = currentTransform
  }
}

extension CanvasHandler {

  /// Entry point for all raw input events from gesture modifiers.
  ///
  /// Global hover location is recorded independently of tool resolution so
  /// public observation does not disappear when a tool claims hover. A tool
  /// with a matching capability may still resolve that hover for its own
  /// canvas adjustment or pointer style.
  ///
  /// Claimed interactions are forwarded to the effective tool's
  /// ``CanvasTool/resolveInteraction(context:currentTransform:)`` method.
  ///
  /// Returns an optional to allow a no-op in ``InteractionModifiers``,
  /// so that interaction modifiers that don't need to touch Transform state
  /// don't inadvertently write it to `identity`.
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
      recordPublicPointerInput(from: context)
      print("No resolution for provided interaction context: \(context)")
      return nil
    }

    let processedTransform = handleAdjustment(
      resolvedAdjustment,
      transform: currentTransform,
    )

    recordPublicPointerInput(from: context)
    return processedTransform
  }

  private func handleAdjustment(
    _ adjustment: InteractionAdjustment,
    transform: TransformState,
  ) -> TransformState? {
    switch adjustment {
      case .transform(let adj):
        return adj.updatedState(transform)

      case .pointer(let adj):
        switch adj {
          case .tap(let point): self.pointer.tap = point
          case .drag(let rect):
            self.pointer.drag = rect
          case .hover(let point): self.pointer.hover = point
        }
        return nil

      case .none: return nil
    }
  }

  private func recordPublicPointerInput(from context: InteractionContext) {
    switch context.interaction {
      case .hover(let location):
        pointer.hover = location

      case .drag(let payload):
        recordPublishedDrag(payload, phase: context.phase)

      default:
        break
    }
  }

  private func recordPublishedDrag(
    _ payload: PointerDragPayload,
    phase: InteractionPhase,
  ) {
    guard let event = PointerDragSnapshot<ViewportSpace>(
      payload: payload,
      phase: phase,
    )
    else { return }

    pointer.latestDrag = event
    if phase.isTerminal {
      pointer.latestDrag = nil
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

    if kind == .drag {
      finishPublishedDrag(with: phase)
    }
  }

  private func finishPublishedDrag(with phase: InteractionPhase) {
    guard phase.isTerminal,
      let event = pointer.latestDrag,
      event.phase.isActive
    else { return }

    pointer.latestDrag = event.withPhase(phase)
//    pointer.drag = nil
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

  /// The committed selection synchronised with an optional parent binding.
  ///
  /// With no tool configuration, CanvasKit's fallback Select tool is the only
  /// valid committed selection.
  var committedToolSelection: ToolSelection {
    get { toolHandler.selection ?? .default }
    set { toolHandler.synchroniseCommittedSelection(newValue) }
  }

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
