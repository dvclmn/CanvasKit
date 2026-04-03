//
//  CanvasInteractionState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import InteractionKit
import SwiftUI

/// `CanvasInteractionState`'s state is owned outside of CanvasKit,
/// by the project *using* CanvasKit. E.g. in the case of DrawString,
/// this is owned by `BaseContainer` view.
@Observable
public final class CanvasInteractionState {

  /// Internal state
  public var transform: TransformState = .identity
  public var pointer: PointerState = .initial

  /// Synced here from `CanvasCoreView`
  private var artworkFrame: Rect<ScreenSpace>?

  /// Values synced here from the Environment
  private var zoomRange: ClosedRange<Double>?
  private var modifiers: Modifiers = []
  private var activeTool: (any CanvasTool)?

  /// The most recent domain action produced by a tool resolution.
  /// Consuming apps can observe this to react to tool-specific events
  /// (e.g. "select at point", "commit stroke").
  public var lastToolAction: ToolAction = .none

  /// The most recent interaction context, provided when
  /// `handleInput(_:phase:)` is called.
  public var phase: InteractionPhase = .none
  public var source: InteractionSource?

  public init() {}
}

extension CanvasInteractionState {

  /// Entry point for all raw input events from gesture modifiers.
  ///
  /// 1. Global gestures (swipe, pinch, hover) are handled centrally here,
  /// via `GlobalInteraction`. Tools never see these events.
  ///
  /// Pointer interactions (tap, drag) are forwarded to the active tool's
  /// `resolvePointerInteraction()` method, subject to `inputCapabilities`.
  public func handleInput(
    _ source: InteractionSource,
    phase: InteractionPhase,
  ) {

    self.source = source
    self.phase = phase

    let resolution = inputResolver.resolve()

    /// 1 – Global gestures
    executeAdjustment(resolution.globalAdjustment)

    /// 2 – Tool-specific pointer interactions
    executeAdjustment(resolution.pointerAdjustment)

    lastToolAction = resolution.toolAction
  }

  public var pointerStyle: PointerStyleCompatible? {
    inputResolver.pointerStyle
  }

  private var inputResolver: CanvasInputResolver {
    .init(
      source: source,
      phase: phase,
      modifiers: modifiers,
      activeTool: activeTool,
      transform: transform,
    )
  }

}

extension CanvasInteractionState {

  public func updateTool(to tool: (any CanvasTool)?) {
    self.activeTool = tool
  }
  public func updateArtworkFrame(to frame: Rect<ScreenSpace>?) {
    self.artworkFrame = frame
  }
  public func updateModifiers(to modifiers: Modifiers) {
    self.modifiers = modifiers
  }
  public func updateZoomRange(to range: ClosedRange<Double>?) {
    self.zoomRange = range
  }

}
extension CanvasInteractionState {
  private func executeAdjustment(_ adjustment: CanvasAdjustment) {
    switch adjustment {
      case .updateTranslation(let size): self.transform.translation = size
      case .updateScale(let scale): self.transform.scale = scale.clampedIfNeeded(to: zoomRange)
      case .updateRotation(let angle): self.transform.rotation = angle
      case .updatePointerDrag(let rect): self.pointer.drag = rect
      case .updatePointerTap(let point): self.pointer.tap = point
      case .updatePointerHover(let point): self.pointer.hover = point
      case .none: break
    }
  }
}

// MARK: - Mapping and Snapshot

extension CanvasInteractionState {

  public func snapshot(in canvasSize: Size<CanvasSpace>) -> CanvasSnapshot? {
    guard let hover = pointer.hover,
      let hoverMapped = coordinateSpaceMapper?.canvasPoint(from: hover),
      let isInside = coordinateSpaceMapper?.isInsideCanvas(hoverMapped, in: canvasSize)
    else { return nil }

    return CanvasSnapshot(
      pointerLocation: hoverMapped,
      isPointerInsideCanvas: isInside,
      zoom: transform.scale,
      pan: transform.translation.cgSize,
      rotation: transform.rotation,
    )
  }

//  /// Exposed for event modifiers that need to convert coordinates.
//  package var coordinateSpaceMapper: CoordinateSpaceMapper? {
//    guard let artworkFrame, let zoomRange else { return nil }
//    return .init(
//      artworkFrame: artworkFrame,
//      zoom: transform.scale,
//      zoomRange: zoomRange,
//    )
//  }
}
