//
//  CanvasHandler.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import BasePrimitives
//import InteractionKit
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
  private var artworkFrame: Rect<ScreenSpace>?

  /// Values synced here from the Environment
  private var modifiers: Modifiers = []
  package var areToolsInUse: Bool = false

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
  ///
  /// Returns an optional to allow a no-op in ``InteractionModifiers``,
  /// so that interaction modifiers that don't need to touch Transform state
  /// don't inadvertantly write it to `identity`.
  func processedTransform(
    _ interaction: Interaction,
    tool: (any CanvasTool)?,
    phase: InteractionPhase,
    currentTransform: TransformState,
  ) -> TransformState? {

    self.interaction = interaction
    self.phase = phase

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

  func updateArtworkFrame(to frame: Rect<ScreenSpace>?) {
    self.artworkFrame = frame
  }
  func updateModifiers(to modifiers: Modifiers) {
    self.modifiers = modifiers
  }

  func pointerStyle(
    tool: any CanvasTool,
    transform: TransformState,
  ) -> PointerStyleCompatible? {
    inputResolver(tool: tool, transform: transform)?.pointerStyle
  }

  private func inputResolver(
    tool: (any CanvasTool)?,
    transform: TransformState,
  ) -> CanvasInputResolver? {
    guard let interaction else { return nil }

    let context = InteractionContext(
      interaction: interaction,
      phase: phase,
      modifiers: modifiers,
    )
    return .init(
      context: context,
      activeTool: tool,
      transform: transform,
    )
  }
}

// MARK: - Mapping and Snapshot

extension CanvasHandler {

//  func snapshot(
//    zoomRange: ClosedRange<Double>?,
//    transform: TransformState,
//    pointer: PointerState,
//    phase: InteractionPhase,
//  ) -> CanvasSnapshot? {
//
//    guard let artworkFrame else { return nil }
//
//    /// Raw zoom for snapshot, clamped zoom for mapper
//    let zoomRaw = transform.scale
//    let zoomClamped = zoomRaw.clampedIfNeeded(to: zoomRange)
//
//    let mapper = CoordinateSpaceMapper(
//      artworkFrame: artworkFrame,
//      zoomClamped: zoomClamped,
//    )
//
//    let tapMapped = pointer.tap.map { mapper.canvasPoint(from: $0) }
//    let hoverMapped = pointer.hover.map { mapper.canvasPoint(from: $0) }
//    let rectMapped = pointer.drag.map { mapper.canvasRect(from: $0) }
//    let isInside = hoverMapped.map { mapper.isInsideCanvas($0) } ?? false
//
//    return CanvasSnapshot(
//      zoom: zoomRaw,
//      pan: transform.translation,
//      rotation: transform.rotation,
//      artworkFrame: artworkFrame,
//      pointerTap: tapMapped,
//      pointerDrag: rectMapped,
//      pointerHover: hoverMapped,
//      isPointerInsideCanvas: isInside,
//      phase: phase,
//    )
//  }
}
