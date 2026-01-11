//
//  Handler+CanvasGesture.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import BasePrimitives
import GestureKit
import SwiftUI

@dynamicMemberLookup
public struct CanvasHandler {

  var gestureHandler: GestureHandler = .init()

  /// Expected to be updated *outside* of `CanvasView`,
  /// by the consuming app.
  //  public var viewportSize: CGSize?

  public var geometry: CanvasGeometry = .init()
  //  @Shared(.canvasGeometry) public var geometry

  /// Expected to be updated from outside `CanvasView`, (i.e. from the caller), when canvas size changes.
  /// `CanvasHandler` does not watch or update canvas dimensions itself.
  ///
  /// Note: This is the source of truth for the ResizeHandler,
  /// to obtain the latest Canvas Size from the Domain View
  //  public var canvasSize: CGSize?

  public var hoverLocation: CGPoint?
  public var tapDragPhase: TapDragPhase?
  //  public var interactions = InteractionHandler()
  public var resizeHandler = ResizeHandler()

  let dragTolerance: CGFloat = 5

  public init() {
    //    print("Initialised `CanvasHandler` at \(Date.debug)")
  }

}

extension CanvasHandler {
  public subscript<T>(dynamicMember keyPath: KeyPath<GestureHandler, T>) -> T {
    gestureHandler[keyPath: keyPath]
  }

  public var viewportSize: CGSize? { geometry.viewportSize }
  public var canvasSize: CGSize? { geometry.canvasSize }

  public mutating func resetGesture(_ transforms: TransformTypes) {
    let kind = GestureKind.Meta(from: transforms)
    gestureHandler.reset(kind)
  }

  public mutating func updateAllowedGesture(_ kind: GestureKind.Meta) {
    gestureHandler.interactions.allowedDragGesture = kind
  }

  public mutating func updateGesture(
    _ kind: GestureKind,
    //    geometry: CanvasGeometry
  ) {
    gestureHandler.update(kind, geometry: geometry)
  }
  public mutating func updateViewportSize(_ size: CGSize) {
    geometry.viewportSize = size
  }

  public mutating func updateCanvasSize(_ size: CGSize) {
    print("Updating canvas size to \(size), at \(Date.debug)")
    geometry.canvasSize = size
    print("Now that geometry is updated, ensuring it got a value: \(geometry)")
  }

  public var transientCanvasSize: CGSize? {
    resizeHandler.transientCanvasSize
  }

  public var canvasAnchor: UnitPoint { resizeHandler.canvasAnchor }

  func isDragAllowed(_ drag: GestureKind.Meta) -> Bool {
    return drag == gestureHandler.interactions.allowedDragGesture
  }

  public var draggedResizePoint: GridBoundaryPoint? {
    resizeHandler.draggedResizePoint
  }

  public var dragRect: CGRect? {
    guard let unmapped = tapDragPhase?.dragValue else { return nil }
    return canvasContext?.dragRect(for: unmapped)
  }

  public var tapLocation: CGPoint? {
    guard let unmapped = tapDragPhase?.tapValue else { return nil }
    return canvasContext?.tapLocation(for: unmapped)
  }

//  public var canvasContext: CanvasTransformContext? {
//    return CanvasTransformContext(
//      viewportSize: geometry.viewportSize,
//      canvasSize: geometry.canvasSize,
//      zoom: gestureHandler.zoomLevel,
//      pan: gestureHandler.panOffset,
//      rotation: gestureHandler.rotation
//    )
//  }

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

  public func removeZoom(from value: CGFloat) -> CGFloat {
    value.removingZoom(gestureHandler.zoomLevel)
  }

  public mutating func handleDrag(
    type: GestureKind,
    _ phase: TapDragPhase
  ) {
    tapDragPhase = phase
    //    interactions.interaction = phase.interactionType
    hoverLocation = nil
    //    print("Handling a Tap/Drag: \(phase)")
  }
  //#if canImport(AppKit)
  mutating func handleKeysHeld(_ keysHeld: Set<KeyEquivalent>) {
    gestureHandler.interactions.keysHeld = keysHeld
    //    self.interactions.keysHeld = keysHeld
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
    removeZoom(from: Styles.sizeTiny)
    //    Styles.sizeTiny.removingZoom(zoomHandler.zoom)
  }
}

extension CanvasHandler: CustomStringConvertible {
  public var description: String {
    return """

      /// CanvasTransform ///
        - Zoom: \(gestureHandler.zoomLevel.displayString)
        - Pan: \(gestureHandler.panOffset.displayString)
        - Rotation (degrees): \(gestureHandler.rotation.degrees.displayString)
        - Viewport size: \(geometry.viewportSize.displayString)
        - Canvas size: \(geometry.canvasSize.displayString)


      """
  }
}

//extension SharedKey where Self == InMemoryKey<CanvasGeometry>.Default {
//  static var canvasGeometry: Self {
//    Self[
//      .inMemory("canvasGeometry"),
//      default: CanvasGeometry(viewportSize: nil, canvasSize: nil)
//    ]
//  }
//}
