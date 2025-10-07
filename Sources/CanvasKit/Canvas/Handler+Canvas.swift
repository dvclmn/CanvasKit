//
//  Handler+CanvasGesture.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import BaseHelpers


import Sharing
import SwiftUI

public struct CanvasGeometry: Sendable, Equatable {
  public var viewportSize: CGSize?
  public var canvasSize: CGSize?

  public init(
    viewportSize: CGSize?,
    canvasSize: CGSize?,
  ) {
    self.viewportSize = viewportSize
    self.canvasSize = canvasSize
  }
}

public struct CanvasHandler {

  public var zoomHandler = ZoomHandler()
  public var panHandler = PanHandler()
  public var rotationHandler = RotationHandler()

  /// Expected to be updated *outside* of `CanvasView`,
  /// by the consuming app.
//  public var viewportSize: CGSize?

  @Shared(.canvasGeometry) public var geometry
  
  /// Expected to be updated from outside `CanvasView`, (i.e. from the caller), when canvas size changes. This View/Handler does not watch or update canvas dimensions itself.
  ///
  /// Note: This is the source of truth for the ResizeHandler,
  /// to obtain the latest Canvas Size from the Domain View
//  public var canvasSize: CGSize?

  public var hoverLocation: CGPoint?
  public var tapDragPhase: TapDragPhase?
  public var interactions = InteractionHandler()
  public var resizeHandler = ResizeHandler()

  let dragTolerance: CGFloat = 5

  public init() {
    print("Initialised `CanvasHandler` at \(Date.now.formatted(date: .omitted, time: .complete))")
  }

}

extension CanvasHandler {
  
  public mutating func updateViewportSize(_ size: CGSize) {
    $geometry.withLock { $0.viewportSize = size }
  }
  
  public mutating func updateCanvasSize(_ size: CGSize) {
    $geometry.withLock { $0.canvasSize = size }
  }

  public var transientCanvasSize: CGSize? {
    resizeHandler.transientCanvasSize
  }

  public var canvasAnchor: UnitPoint { resizeHandler.canvasAnchor }

  public mutating func addDebugResize(
    size: CGSize?,
    boundaryPoint: ResizePoint?
  ) {
    let newSize = size ?? geometry.canvasSize
    resizeHandler.transientCanvasSize = newSize
    resizeHandler.draggedResizePoint = boundaryPoint
  }

  func isDragAllowed(_ drag: DragGestureKind) -> Bool {
    return drag == interactions.allowedDragGesture
  }

  public var draggedResizePoint: ResizePoint? {
    resizeHandler.draggedResizePoint
  }

  public var dragRect: CGRect? {
    guard let unmapped = tapDragPhase?.unMappedDragRect else { return nil }
    return canvasContext?.dragRect(for: unmapped)
  }

  public var tapLocation: CGPoint? {
    guard let unmapped = tapDragPhase?.unMappedTapLocation else { return nil }
    return canvasContext?.tapLocation(for: unmapped)
  }

  public var canvasContext: CanvasTransformContext? {
    return CanvasTransformContext(
      viewportSize: geometry.viewportSize,
      canvasSize: geometry.canvasSize,
      zoom: zoomHandler.zoom,
      pan: panHandler.pan,
      rotation: rotationHandler.rotation
    )
  }

 

  public mutating func resetTransforms(_ transforms: TransformTypes) {
    if transforms.contains(.zoom) {
      zoomHandler.reset()
    }
    if transforms.contains(.pan) {
      panHandler.reset()
    }
    if transforms.contains(.rotation) {
      rotationHandler.reset()
    }
  }

  public mutating func handleHover(_ phase: HoverPhase) {

    guard let context = canvasContext else { return }

    switch phase {
      case .active(let location):
        let mapped = context.mapToCanvas(viewportPoint: location)
        hoverLocation = mapped

      /// Note: This only triggers when the pointer exits the view.
      /// *Not* when the movement of the pointer stops
      case .ended:
        hoverLocation = nil
    }
  }

  public mutating func handleGesturePanPhase(_ phase: PanPhase) {
    switch phase {
      case .active(let delta):
        interactions.interaction = .gesturePan
        panHandler.applyPanDelta(delta)

      case .ended, .inactive, .cancelled:
        interactions.interaction = .none

    }
  }

  // MARK: - Handle Zoom
  public mutating func handleZoom(_ phase: ZoomPhase) {
    switch phase {
      case .active(_):
        interactions.interaction = .gestureZoom

      case .ended, .inactive:
        interactions.interaction = .none

    }
  }

  public func removeZoom(from value: CGFloat) -> CGFloat {
    return value.removingZoom(zoomHandler.zoom, clampedTo: zoomHandler.zoomRange)
  }

  public mutating func handleDrag(
    type: DragGestureKind,
    _ phase: TapDragPhase
  ) {
    tapDragPhase = phase
    //    interactions.interaction = phase.interactionType
    hoverLocation = nil
    //    print("Handling a Tap/Drag: \(phase)")
  }
//#if canImport(AppKit)
  mutating func handleKeysHeld(_ keysHeld: Set<KeyEquivalent>) {
    self.interactions.keysHeld = keysHeld
  }
//#endif

  //  public var pointerStyle: PointerStyleCompatible? {
  //    return switch (interactions.isDragging, interactions.keysHeld.isHoldingSpace) {
  //      case (true, true): .grabActive
  //      case (false, true): .grabIdle
  //      default: nil
  //    }
  //  }

  public var cornerRounding: CGFloat {
    Styles.sizeTiny.removingZoom(zoomHandler.zoom)
  }
}

extension CanvasHandler: CustomStringConvertible {
  public var description: String {
    return """

      /// CanvasTransform ///
        - Zoom: \(zoomHandler.zoom.displayString)
        - Pan: \(panHandler.pan.displayString)
        - Rotation (degrees): \(rotationHandler.rotation.degrees.displayString)
        - Viewport size: \(geometry.viewportSize?.displayString ?? "nil")
        - Canvas size: \(geometry.canvasSize?.displayString ?? "nil")


      """
  }
}

extension SharedKey where Self == InMemoryKey<CanvasGeometry>.Default {
  static var canvasGeometry: Self {
    Self[
      .inMemory("canvasGeometry"),
      default: CanvasGeometry(viewportSize: nil, canvasSize: nil)
    ]
  }
}
