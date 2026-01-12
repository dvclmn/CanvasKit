//
//  Handler+CanvasGesture.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import CoreTools
import GestureKit
import SwiftUI

//@dynamicMemberLookup
//@Observable
public final class CanvasHandler {
  //public struct CanvasHandler {

  //  var pointer: PointerStream?
  var panGesture: PanGestureStream = .centered
  //  var magnifyGesture: MagnificationStream

  public var geometry: CanvasGeometry = .init()

  //  public var gestureState: GestureContext

  //  public var interactions = InteractionHandler()
    public var resizeHandler = ResizeHandler()

  let dragTolerance: CGFloat = 5

  public init() {
    //    print("Initialised `CanvasHandler` at \(Date.debug)")
  }

}

extension CanvasHandler {
  var panOffset: CGSize { panGesture.clamped(to: geometry, zoom: 1.0) }

  //  public subscript<T>(dynamicMember keyPath: KeyPath<InteractionHandler, T>) -> T {
  //    interactions[keyPath: keyPath]
  //  }

  public var viewportSize: CGSize? { geometry.viewportSize }
  public var canvasSize: CGSize? { geometry.canvasSize }

  //  public mutating func resetGesture(_ transforms: TransformTypes) {
  //    let kind = InteractionKind.Meta(from: transforms)
  //    gestureHandler.reset(kind)
  //  }

  //  public func updateAllowedGesture(_ kind: InteractionKind.Meta) {
  //    interactions.allowed = kind
  //  }
  public func updateViewportSize(_ size: CGSize) {
    print("Updating Viewport size to \(size), at \(Date.debug)")
    geometry.viewportSize = size
    print("Now that Viewport size is updated, ensuring it got a value: \(geometry)")
  }
  public func updateCanvasSize(_ size: CGSize) {
    print("Updating canvas size to \(size), at \(Date.debug)")
    geometry.canvasSize = size
    print("Now that Canvas size is updated, ensuring it got a value: \(geometry)")
  }

  //  public mutating func updateGesture(
  //    _ kind: GestureKind,
  //    //    geometry: CanvasGeometry
  //  ) {
  //    gestureHandler.update(kind, phase:  geometry: geometry)
  //  }

//  public var transientCanvasSize: CGSize? {
//    resizeHandler.transientCanvasSize
//  }

  public var canvasAnchor: UnitPoint { resizeHandler.canvasAnchor }

  //  func isDragAllowed(_ drag: InteractionKind.Meta) -> Bool {
  //    return drag == interactions.allowed
  //  }

//  public var draggedResizePoint: GridBoundaryPoint? {
//    resizeHandler.draggedResizePoint
//  }

  //  public func handleHover(_ phase: HoverPhase) {
  //
  //    //    guard let context = canvasContext else { return }
  //
  //    switch phase {
  //      case .active(let location):
  //        interactions.updateGesture(
  //          .hover(location),
  //          phase: .changed,
  //          modifiers: nil
  //        )
  //        //        let mapped = context.mapToCanvas(viewportPoint: location)
  //        //        hoverLocation = mapped
  //
  //        /// Note: This only triggers when the pointer exits the view.
  //        /// *Not* when the movement of the pointer stops
  //      case .ended:
  //        interactions.reset(.hover)
  //        //        hoverLocation = nil
  //    }
  //  }

  //  public func removeZoom(from value: CGFloat) -> CGFloat {
  //    value.removingZoom(interactions.zoom)
  //  }

  //  public var cornerRounding: CGFloat {
  //    removeZoom(from: Styles.sizeTiny)
  //    //    Styles.sizeTiny.removingZoom(zoomHandler.zoom)
  //  }

  //  public var dragRect: CGRect? {
  //    guard let unmapped = pointerPhase?.dragValue else { return nil }
  //    return canvasContext?.dragRect(for: unmapped)
  //  }
  //
  //  public var tapLocation: CGPoint? {
  //    guard let unmapped = pointerPhase?.tapValue else { return nil }
  //    return canvasContext?.tapLocation(for: unmapped)
  //  }

  //  public var canvasContext: CanvasTransformContext? {
  //    return CanvasTransformContext(
  //      viewportSize: geometry.viewportSize,
  //      canvasSize: geometry.canvasSize,
  //      zoom: gestureHandler.zoomLevel,
  //      pan: gestureHandler.panOffset,
  //      rotation: gestureHandler.rotation
  //    )
  //  }

  //  public mutating func handleDrag(
  //
  ////    type: GestureKind,
  ////    _ phase: PointerPhase
  //  ) {
  ////    pointerPhase = phase
  //    //    interactions.interaction = phase.interactionType
  //    hoverLocation = nil
  //    //    print("Handling a Tap/Drag: \(phase)")
  //  }
  //#if canImport(AppKit)
  //  mutating func handleKeysHeld(_ keysHeld: Set<KeyEquivalent>) {
  //    gestureHandler.interactions.keysHeld = keysHeld
  //    //    self.interactions.keysHeld = keysHeld
  //  }
  //#endif

  //  public var pointerStyle: PointerStyleCompatible? {
  //    return switch (interactions.isDragging, interactions.keysHeld.isHoldingSpace) {
  //      case (true, true): .grabActive
  //      case (false, true): .grabIdle
  //      default: nil
  //    }
  //  }

}

//extension CanvasHandler: CustomStringConvertible {
//  public var description: String {
//    return """
//
//      /// CanvasTransform ///
//        - Zoom: \(gestureHandler.zoom.displayString)
//        - Pan: \(gestureHandler.panOffset.displayString)
//        - Rotation (degrees): \(gestureHandler.rotation.degrees.displayString)
//        - Viewport size: \(geometry.viewportSize.displayString)
//        - Canvas size: \(geometry.canvasSize.displayString)
//
//
//      """
//  }
//}

//extension SharedKey where Self == InMemoryKey<CanvasGeometry>.Default {
//  static var canvasGeometry: Self {
//    Self[
//      .inMemory("canvasGeometry"),
//      default: CanvasGeometry(viewportSize: nil, canvasSize: nil)
//    ]
//  }
//}
