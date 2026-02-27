//
//  Handler+CanvasGesture.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import CoreTools
import GestureKit
import SwiftUI

@Observable
public final class CanvasHandler {

  /// Canvas transform interactions
  var panGesture: PanState = .initial
  var zoomGesture: ZoomState = .initial
  var rotateGesture: RotateState = .initial

  var pointerTap: TapState = .init()
  var pointerDrag: DragState = .init()
  var pointerHover: RotateState = .init()

  /// Pointer-based interactions
  //  var pointerState: PointerState = .initial

  //  public var geometry: CanvasGeometry = .init()

  //  public var resizeHandler = ResizeHandler()

  /// This is provided from outside via the environment
  var zoomRange: ClosedRange<Double>?

  //  let zoomRange: ClosedRange<Double> = 0.2...20

  /// This was previously set to `continuous(axes: .horizontal)` for testing
  var activeDragType: DragBehavior = .none
  //  var activeDragType: DragBehavior? = nil
  //  var activeDragType: DragBehavior = .continuous(axes: .horizontal)
  //  var activeDragType: DragBehavior = .marquee(drawMarquee: true)
  //  var activeDragType: DragType = .marquee

  @ObservationIgnored let dragTolerance: CGFloat = 5

  public init() {}
}

extension CanvasHandler {

  public var currentPointerInteraction: PointerInteraction.Meta? {
    if pointerTap.isActive { return .tap }
    if pointerDrag.isActive { return .drag }
    if pointerHover.isActive { return .hover }
    return nil
  }
  public var isPerformingGesture: Bool {
    panGesture.isActive || zoomGesture.isActive || rotateGesture.isActive
  }

  public var zoomClamped: Double {
    guard let zoomRange else { return 1.0 }
    return zoomGesture.zoom(clampedTo: zoomRange)
  }

  public var pan: CGSize { panGesture.pan }

  @MainActor
  public func dragRectBinding() -> Binding<CGRect?> {
    return switch activeDragType {
      case .marquee:
        Binding {
          let value = self.pointerDrag.value
          //          print("Marquee Mode. GET Value: \(value?.displayString, default: "nil")")
          return value
        } set: {
          self.pointerDrag.value = $0
        }

      case .continuous:
        Binding {
          let value = self.panGesture.pan.toCGRectZeroOrigin
          //          print("Continuous Mode. GET Value: \(value)")
          return value
        } set: {
          self.panGesture.update($0?.size ?? .zero, phase: .changed)
        }

      case .none:
        .constant(nil)

    }

  }

  //  @MainActor
  //  public func cumulativeDragPanBinding() -> Binding<CGSize> {
  //    Binding {
  //      self.pan
  //    } set: {
  //      self.panGesture.update($0, phase: .changed)
  //    }
  //
  //  }

  public func updateViewportRect(_ rect: CGRect) {
    //    print("Updating Viewport size to \(size), at \(Date.debug)")
    geometry.viewportRect = rect
    //    print("Now that Viewport size is updated, ensuring it got a value: \(geometry)")
  }
  public func updateCanvasSize(_ size: CGSize) {
    //    print("Updating canvas size to \(size), at \(Date.debug)")
    geometry.canvasSize = size
    //    print("Now that Canvas size is updated, ensuring it got a value: \(geometry)")
  }
  public var canvasAnchor: UnitPoint { resizeHandler.canvasAnchor }

  public func removeZoom(from value: CGFloat) -> CGFloat {
    value.removingZoom(zoomClamped)
    //      zoomGesture.
    //      value.removingZoom()
  }

  //  public var cornerRounding: CGFloat {
  //    removeZoom(from: Styles.sizeTiny)
  //    //    Styles.sizeTiny.removingZoom(zoomHandler.zoom)
  //  }
}
//  var panOffset: CGSize { panGesture.clamped(to: geometry, zoom: 1.0) }

//  public subscript<T>(dynamicMember keyPath: KeyPath<InteractionHandler, T>) -> T {
//    interactions[keyPath: keyPath]
//  }

//  public var viewportSize: CGSize? { geometry.viewportSize }
//  public var canvasSize: CGSize? { geometry.canvasSize }

//  public mutating func resetGesture(_ transforms: TransformTypes) {
//    let kind = InteractionKind.Meta(from: transforms)
//    gestureHandler.reset(kind)
//  }

//  public func updateAllowedGesture(_ kind: InteractionKind.Meta) {
//    interactions.allowed = kind
//  }

//  public mutating func updateGesture(
//    _ kind: GestureKind,
//    //    geometry: CanvasGeometry
//  ) {
//    gestureHandler.update(kind, phase:  geometry: geometry)
//  }

//  public var transientCanvasSize: CGSize? {
//    resizeHandler.transientCanvasSize
//  }

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

//}

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
