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
  /// `handleInput(_:phase:)` is called.
  public var phase: InteractionPhase = .none
  public var source: InteractionSource?

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
  public func handleInput(
    _ source: InteractionSource,
    phase: InteractionPhase,
  ) {

    self.source = source
    self.phase = phase

    guard let resolution = inputResolver?.resolve() else { return }

    /// 1 – Global gestures
    executeAdjustment(resolution.globalAdjustment)

    /// 2 – Tool-specific pointer interactions
    executeAdjustment(resolution.pointerAdjustment)

    lastToolAction = resolution.toolAction
  }

  public var pointerStyle: PointerStyleCompatible? {
    inputResolver?.pointerStyle
  }

  private var inputResolver: CanvasInputResolver? {
    guard let source else { return nil }
    return .init(
      source: source,
      phase: phase,
      modifiers: modifiers,
      activeTool: activeTool,
      transform: transform,
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
  //  public func updateZoomRange(to range: ClosedRange<Double>?) {
  //    self.zoomRange = range
  //  }

}
extension CanvasHandler {

  private func executeAdjustment(_ adjustment: CanvasAdjustment) {
    switch adjustment {
      case .updateTranslation(let size): self.transform.translation = size
      case .updateScale(let scale): self.transform.scale = scale
      //      case .updateScale(let scale): self.transform.scale = scale.clampedIfNeeded(to: zoomRange)
      case .updateRotation(let angle): self.transform.rotation = angle
      case .updatePointerDrag(let rect): self.pointer.drag = rect
      case .updatePointerTap(let point): self.pointer.tap = point
      case .updatePointerHover(let point): self.pointer.hover = point
      case .none: break
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
      pointerTap: tapMapped,
      pointerLocation: hoverMapped,
      pointerDrag: rectMapped,
      isPointerInsideCanvas: isInside,
      artworkFrame: artworkFrame,
      zoom: zoomRaw,
      pan: transform.translation,
      rotation: transform.rotation,
      phase: phase,
    )
  }
}
