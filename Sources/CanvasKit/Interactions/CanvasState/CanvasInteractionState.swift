//
//  CanvasInteractionState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import GeometryPrimitives
import InteractionPrimitives
import SwiftUI

/// `CanvasInteractionState`'s state is owned outside of CanvasKit,
/// by the project *using* CanvasKit. E.g. in the case of DrawString,
/// this is owned by `BaseContainer` view.
@Observable
public final class CanvasInteractionState {

  public var transform: TransformState = .identity
  public var pointer: PointerState = .initial
  public var geometry: CanvasGeometry?
  public var zoomRange: ClosedRange<Double>?
  public var modifiers: Modifiers = []

  /// Synced here via the Env
  public var activeTool: (any CanvasTool)?

  /// The most recent domain action produced by a tool resolution.
  /// Consuming apps can observe this to react to tool-specific events
  /// (e.g. "select at point", "commit stroke").
  public var lastToolAction: ToolAction = .none

  /// The most recent interaction context.
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

  public var snapshot: CanvasSnapshot? {
    guard let hover = pointer.hover,
      let hoverMapped = coordinateSpaceMapper?.canvasPoint(from: hover),
      let isInside = coordinateSpaceMapper?.isInsideCanvas(hoverMapped)
    else { return nil }

    return CanvasSnapshot(
      pointerLocation: hoverMapped,
      isPointerInsideCanvas: isInside,
      zoom: transform.scale,
      pan: transform.translation.cgSize,
      rotation: transform.rotation,
    )
  }

  /// Exposed for event modifiers that need to convert coordinates.
  package var coordinateSpaceMapper: CoordinateSpaceMapper? {
    guard let geometry, let zoomRange else { return nil }
    return .init(
      canvasSize: geometry.canvasSize,
      artworkFrame: geometry.artworkFrameInViewport,
      zoom: transform.scale,
      zoomRange: zoomRange,
    )
  }
}
