//
//  CanvasHandler.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import BasePrimitives
import InteractionKit
import SwiftUI

/// `CanvasHandler`'s state is owned outside of CanvasKit,
/// by the project *using* CanvasKit. E.g. in the case of DrawString,
/// this is owned by `BaseContainer` view.
@Observable
final class CanvasHandler {

  /// Internal state
  //  var transform: TransformState = .identity
  var pointer: PointerState = .initial

  /// Synced here from `CanvasCoreView`. This then gets added
  /// to the Environment by CanvasSnapshot
  private var artworkFrame: Rect<ScreenSpace>?

  /// Values synced here from the Environment
  private var modifiers: Modifiers = []
  package var activeTool: (any CanvasTool)?

  /// The most recent domain action produced by a tool resolution.
  /// Consuming apps can observe this to react to tool-specific events
  /// (e.g. "select at point", "commit stroke").
  var lastToolAction: ToolAction = .none

  /// The most recent interaction context, provided when
  /// `handleInteraction(_:phase:)` is called.
  var phase: InteractionPhase = .none
  var interaction: Interaction?

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
  func processedTransform(
    _ interaction: Interaction,
    phase: InteractionPhase,
    currentTransform: TransformState,
  ) -> TransformState {

    self.interaction = interaction
    self.phase = phase

    let resolver = inputResolver(transform: currentTransform)
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
      return handleAdjustment(toolAdjustment, currentTransform: currentTransform)
      //      updatePointer()
    }

    lastToolAction = resolution.toolResolution?.action ?? .none
    return .identity
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
      //        switch adj {
      //          case .translation(let size): self.transform.translation = size
      //          case .scale(let scale): self.transform.scale = scale
      //          case .rotation(let angle): self.transform.rotation = angle
      //        }

      case .pointer(let adj):
        switch adj {
          case .tap(let point): self.pointer.tap = point
          case .drag(let rect): self.pointer.drag = rect
          case .hover(let point): self.pointer.hover = point
        }
        return currentTransform

    }
  }

  //  private func updateTransform(
  //    current transform: TransformState,
  //    adjustment: TransformAdjustment,
  //  ) -> TransformState {
  //    adjustment.updatedState(transform)
  //
  //  }
  //
  //  private func updatePointer(_ adjustment: PointerAdjustment) {
  //    //  private func updatePointer(_ adjustment: InteractionAdjustment) -> PointerState {
  //    switch adjustment {
  //      case .tap(let point): self.pointer.tap = point
  //      case .drag(let rect): self.pointer.drag = rect
  //      case .hover(let point): self.pointer.hover = point
  //    }
  //  }
}

extension CanvasHandler {

  func updateTool(to tool: (any CanvasTool)?) {
    self.activeTool = tool
  }
  func updateArtworkFrame(to frame: Rect<ScreenSpace>?) {
    self.artworkFrame = frame
  }
  func updateModifiers(to modifiers: Modifiers) {
    self.modifiers = modifiers
  }

  func pointerStyle(transform: TransformState) -> PointerStyleCompatible? {
    inputResolver(transform: transform)?.pointerStyle
  }

  private func inputResolver(transform: TransformState) -> CanvasInputResolver? {
    guard let interactionContext else { return nil }
    return .init(
      context: interactionContext,
      //      source: source,
      //      phase: phase,
      //      modifiers: modifiers,
      activeTool: activeTool,
      transform: transform,
    )
  }

  private var interactionContext: InteractionContext? {
    guard let interaction else { return nil }
    return .init(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
    )
  }
}

// MARK: - Mapping and Snapshot

extension CanvasHandler {

  func snapshot(
    zoomRange: ClosedRange<Double>?,
    transform: TransformState
  ) -> CanvasSnapshot? {

    guard let artworkFrame else { return nil }

    let zoomRaw = transform.scale
    let zoomClamped = zoomRaw.clampedIfNeeded(to: zoomRange)

    let mapper = CoordinateSpaceMapper(
      artworkFrame: artworkFrame,
      zoomClamped: zoomClamped,
    )

    let tapMapped = pointer.tap.map { mapper.canvasPoint(from: $0) }
    let hoverMapped = pointer.hover.map { mapper.canvasPoint(from: $0) }
    let rectMapped = pointer.drag.map { mapper.canvasRect(from: $0) }
    let isInside = hoverMapped.map { mapper.isInsideCanvas($0) } ?? false

    return CanvasSnapshot(
      zoom: zoomRaw,
      pan: transform.translation,
      rotation: transform.rotation,
      artworkFrame: artworkFrame,
      pointerTap: tapMapped,
      pointerDrag: rectMapped,
      pointerHover: hoverMapped,
      isPointerInsideCanvas: isInside,
      phase: phase,
    )
  }
}
