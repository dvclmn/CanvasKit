//
//  CanvasHandler.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import BasePrimitives
import SwiftUI

/// `CanvasHandler`'s state is owned outside of CanvasKit,
/// by the project *using* CanvasKit. E.g. in the case of DrawString,
/// this is owned by `BaseContainer` view.
@Observable
final class CanvasHandler {

  /// Internal state
  var pointer: PointerState = .initial

  /// Synced here from `CanvasCoreView`. This then gets added
  /// to the Environment by CanvasSnapshot
  //  private var artworkFrame: Rect<ScreenSpace>?

  /// Values synced here from the Environment
  //  private var modifiers: Modifiers = []
  package var toolHandlingActive: Bool = false

  /// The most recent domain action produced by a tool resolution.
  /// Consuming apps can observe this to react to tool-specific events
  /// (e.g. "select at point", "commit stroke").
  var lastToolAction: ToolAction = .none

  /// The most recent interaction context, provided when
  /// `handleInteraction(_:phase:)` is called.
  //  var phase: InteractionPhase = .none
  //  var interaction: Interaction?
  private var activeTool: (any CanvasTool)?

  var interactionContext: InteractionContext?

  public init() {}
}

extension CanvasHandler {

  /// Entry point for all raw input events from gesture modifiers.
  ///
  /// 1. Global gestures (swipe, pinch, hover) are handled centrally here.
  /// Tools never see these events.
  ///
  /// Pointer interactions (tap, drag) are forwarded to the active tool's
  /// `resolvePointerInteraction()` method, subject to `inputCapabilities`.
  ///
  /// Returns an optional to allow a no-op in ``InteractionModifiers``,
  /// so that interaction modifiers that don't need to touch Transform state
  /// don't inadvertantly write it to `identity`.
  func processedTransform(
    _ interaction: Interaction,
    tool: (any CanvasTool)?,
    phase: InteractionPhase,
    modifiers: Modifiers,
    currentTransform: TransformState,
  ) -> TransformState? {

    self.activeTool = tool
    //    self.interaction = interaction
    //    self.phase = phase
    let context = InteractionContext(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
    )
    self.interactionContext = context

    let resolver = inputResolver(
      tool: tool,
      transform: currentTransform,
    )

    guard let resolution = resolver?.resolve() else {
      return currentTransform
    }

    /// 1 – Base gestures, updates transform state regardless
    /// of whether Canvas Tools are in use
    if let base = resolution.baseAdjustment {
      return handleAdjustment(.transform(base), currentTransform: currentTransform)
    }

    /// 2 – Tool-specific pointer interactions
    if let toolAdjustment = resolution.toolResolution?.adjustment {
      lastToolAction = resolution.toolResolution?.action ?? .none
      return handleAdjustment(toolAdjustment, currentTransform: currentTransform)
    }

    return nil
  }

}

extension CanvasHandler {

  private func handleAdjustment(
    _ adjustment: InteractionAdjustment,
    currentTransform: TransformState,
  ) -> TransformState {
    switch adjustment {
      case .transform(let adj):
        return adj.updatedState(currentTransform)

      case .pointer(let adj):
        switch adj {
          case .tap(let point): self.pointer.tap = point
          case .drag(let rect): self.pointer.drag = rect
          case .hover(let point): self.pointer.hover = point
        }
        return currentTransform

      case .none: return currentTransform
    }
  }
}

extension CanvasHandler {
  private func isEnabled(
    for interaction: InteractionKinds.Element
  ) -> Bool {
    let inputCapabilities: InteractionKinds = {
      guard let activeTool else { return .noToolsMode }
      return activeTool.inputCapabilities
    }()
    return inputCapabilities.contains(interaction)
  }

  var pointerStyle: PointerStyleCompatible? {
//  func pointerStyle(for tool: any CanvasTool) -> PointerStyleCompatible? {
    guard let interactionContext else { return nil }
    return tool.resolvePointerStyle(context: interactionContext)
  }

  private func inputResolver(
    tool: (any CanvasTool)?,
    transform: TransformState,
  ) -> CanvasInputResolver? {
    guard let interactionContext else { return nil }
    //    guard let interaction else { return nil }
    //
    //    let context = InteractionContext(
    //      interaction: interaction,
    //      phase: phase,
    //      modifiers: modifiers,
    //    )
    return .init(
      context: interactionContext,
      activeTool: tool,
      transform: transform,
    )
  }
}
