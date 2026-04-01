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

// MARK: - Input handling (two-tier resolution)

extension CanvasInteractionState {

  /// Entry point for all raw input events from gesture modifiers.
  ///
  /// 1. Global gestures (swipe, pinch, hover) are handled centrally here,
  /// via `GlobalInteraction`. Tools never see these events.
  ///
  /// Pointer interactions (tap, drag) are forwarded to the active tool's
  /// `resolvePointerInteraction()` method.
  public func handleInput(
    _ source: InteractionSource,
    phase: InteractionPhase,
  ) {

    self.source = source
    self.phase = phase

    /// 1 – Global gestures
    executeAdjustment(globalAdjustment)

    /// 2 – Tool-specific pointer interactions
    //    let pointerAdjustment = pointerAdjustment()
    executeAdjustment(pointerAdjustment)

  }
  private var pointerAdjustment: CanvasAdjustment {

    guard let activeTool else { return .none }

    let resolution = activeTool.resolvePointerInteraction(
      context: InteractionContext(
        source: source,
        phase: phase,
        modifiers: modifiers,
      ),
      currentTransform: transform,
    )

    self.lastToolAction = resolution.action
    return resolution.adjustment
  }

  private var globalAdjustment: CanvasAdjustment {
    guard let source else { return .none }

    return switch source {
      case .swipeGesture(let delta, _): handleGlobalSwipe(delta: delta)
      case .pinchGesture(let scale): .updateScale(scale)
      case .continuousHover(let point): .updatePointerHover(point)
      case .pointerTapGesture, .pointerDragGesture:
        // Pointer events are handled by the active tool
        .none
    }
  }

}

extension CanvasInteractionState {

  public func updateTool(to tool: (any CanvasTool)?) {
    self.activeTool = tool
  }

  //  private func handleGlobalInteraction() -> CanvasAdjustment? {
  //
  //    guard let source else { return nil }
  //
  //    return switch source {
  //      case .swipeGesture(let delta, _): handleGlobalSwipe(delta: delta)
  //      case .pinchGesture(let scale): .updateScale(scale)
  //      case .continuousHover(let point): .updatePointerHover(point)
  //
  //      /// Pointer events are handled on a per-Tool basis.
  //      /// Returning nil here to fall through to `handlePointerInteraction`
  //      /// in `CanvasInteractionState` for tap and drag gestures.
  //      case .pointerTapGesture, .pointerDragGesture: nil
  //
  //    }
  //  }

  private func handleGlobalSwipe(delta: Size<ScreenSpace>) -> CanvasAdjustment {

    /// If Option is held during a Swipe, it is interpreted as Zoom, not Pan
    guard modifiers.contains(.option) else {
      let newTranslation = transform.translation + delta
      return .updateTranslation(newTranslation)
    }

    /// Each point contributes up to 0.5% zoom change at sensitivity = 1.0
    let factor = ZoomComputation.factorFromDelta(
      CGSize(width: 0, height: delta.cgSize.height),
      weights: .vertical,
    )

    //    let newScale = transform.scale * factor
    //    return .updateScale(newScale)
    return .zoomAdjustment(for: transform, by: factor)

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

  public func pointerStyle(with modifiers: Modifiers) -> PointerStyleCompatible? {
    activeTool?.resolvePointerStyle(
      context: InteractionContext(
        source: source,
        phase: phase,
        modifiers: modifiers,
      )
    )
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
  public var coordinateSpaceMapper: CoordinateSpaceMapper? {
    guard let geometry, let zoomRange else { return nil }
    return .init(
      canvasSize: geometry.canvasSize,
      artworkFrame: geometry.artworkFrameInViewport,
      zoom: transform.scale,
      zoomRange: zoomRange,
    )
    //    return .init(
    //      geometry: geometry,
    //      transform: transform,
    //      zoomRange: zoomRange
    //    )
  }
}
