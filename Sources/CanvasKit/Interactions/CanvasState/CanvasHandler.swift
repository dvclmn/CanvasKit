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
public final class CanvasHandler {

  /// Internal state
  public var transform: TransformState = .identity
  public var pointer: PointerState = .initial

  /// Synced here from `CanvasCoreView`. This then gets added
  /// to the Environment by CanvasSnapshot
  private var artworkFrame: Rect<ScreenSpace>?

  /// Values synced here from the Environment
  private var modifiers: Modifiers = []
  private var activeTool: (any CanvasTool)?

  /// The most recent domain action produced by a tool resolution.
  /// Consuming apps can observe this to react to tool-specific events
  /// (e.g. "select at point", "commit stroke").
  public var lastToolAction: ToolAction = .none

  /// The most recent interaction context, provided when
  /// `handleInteraction(_:phase:)` is called.
  public var phase: InteractionPhase = .none
  public var interaction: Interaction?
  //  public var source: InteractionSource?

  public init() {}
}

extension CanvasHandler {

  /// Entry point for all raw input events from gesture modifiers.
  ///
  /// 1. Global gestures (swipe, pinch, hover) are handled centrally here,
  /// via `GlobalInteraction`. Tools never see these events.
  ///
  /// Pointer interactions (tap, drag) are forwarded to the active tool's
  /// `resolvePointerInteraction()` method, subject to `inputCapabilities`.
  public func handleInteraction(
    _ interaction: Interaction,
    //    _ source: InteractionSource,
    phase: InteractionPhase,
  ) {

    self.interaction = interaction
    self.phase = phase

    guard let resolution = inputResolver?.resolve() else { return }

    /// 1 – Global gestures
    if let global = resolution.globalAdjustment {
      executeAdjustment(.transform(global))
    }

    /// 2 – Tool-specific pointer interactions
    if let toolAdjustment = resolution.toolResolution?.adjustment {
      executeAdjustment(toolAdjustment)
    }

    lastToolAction = resolution.toolResolution?.action ?? .none
  }

  public var pointerStyle: PointerStyleCompatible? {
    inputResolver?.pointerStyle
  }

  private var inputResolver: CanvasInputResolver? {
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

extension CanvasHandler {

  public func updateTool(to tool: (any CanvasTool)?) {
    self.activeTool = tool
  }
  public func updateArtworkFrame(to frame: Rect<ScreenSpace>?) {
    self.artworkFrame = frame
  }
  public func updateModifiers(to modifiers: Modifiers) {
    self.modifiers = modifiers
  }
}
extension CanvasHandler {

  private func executeAdjustment(_ adjustment: InteractionAdjustment) {
    switch adjustment {
      case .transform(let adj):
        switch adj {
          case .translation(let size): self.transform.translation = size
          case .scale(let scale): self.transform.scale = scale
          case .rotation(let angle): self.transform.rotation = angle
        }

      case .pointer(let adj):
        switch adj {
          case .tap(let point): self.pointer.tap = point
          case .drag(let rect): self.pointer.drag = rect
          case .hover(let point): self.pointer.hover = point
        }

    }
  }
}

// MARK: - Mapping and Snapshot

extension CanvasHandler {

  func snapshot(zoomRange: ClosedRange<Double>?) -> CanvasSnapshot? {

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
      pointerTap: tapMapped,
      pointerDrag: rectMapped,
      pointerHover: hoverMapped,
      isPointerInsideCanvas: isInside,
      artworkFrame: artworkFrame,
      phase: phase,
    )
  }
}
