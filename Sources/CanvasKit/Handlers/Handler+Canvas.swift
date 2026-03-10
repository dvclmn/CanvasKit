//
//  Handler+CanvasGesture.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/6/2025.
//

import BasePrimitives
import GestureKit
import SwiftUI

@Observable
public final class CanvasHandler {

  //  var transform: TransformState = .initial
  //  var pointer: PointerState = .initial
  var zoomRange: ClosedRange<Double>?

  var canvasFrameInViewport: CGRect?
  var canvasSize: Size<CanvasSpace>?

  var zoomFocusResolver: ZoomFocusResolver = .latchedPointerOrViewportCentre
  var activeDragType: DragBehavior = .none

  public init() {}
}

extension CanvasHandler {
  func pointerMapper(
    zoom: CGFloat?
  ) -> PointerHandler? {
    //  var pointerMapper: PointerHandler? {
    guard let zoomRange, let zoom else { return nil }
    return .init(
      canvasSize: canvasSize,
      artworkFrameInViewport: canvasFrameInViewport,
      zoom: zoom,
      //      zoom: transform.zoomState.zoom,
      zoomRange: zoomRange.toCGFloatRange
    )
  }
  //  private var pointerHandler: PointerHandler? {
  //    guard let zoomRange else { return nil }
  //    return .init(
  //      canvasSize: canvasSize,
  //      artworkFrameInViewport: artworkFrameInViewport,
  //      zoom: zoomLevel,
  //      zoomRange: zoomRange.toCGFloatRange
  //    )
  //  }

  func mappedTapLocation(
    _ location: CGPoint,
    zoom: CGFloat?
  ) -> CGPoint? {
    pointerMapper(zoom: zoom)?.canvasPoint(fromViewportPoint: location)
    //    pointer.pointerTap.update(mapped)
    //    return mapped
  }

  func mappedHoverLocation(
    _ phase: HoverPhase,
    zoom: CGFloat?
  ) -> CGPoint? {
    guard
      let location =
        switch phase {
          case .active(let val): val
          case .ended: nil
        }
    else { return nil }
    return pointerMapper(zoom: zoom)?.canvasPoint(fromViewportPoint: location)
//    let mappedHover = pointerMapper(zoom: zoom)?.canvasPoint(fromViewportPoint: location)
//    pointer.pointerHover.update(mappedHover)
  }

//  func clearLatchedZoomFocusIfNeeded(
//    for phase: InteractionPhase
//  ) {
//    guard !phase.isActive else { return }
//    transform.latchedZoomFocusGlobal = nil
//  }

  //  var zoomClamped: CGFloat {  }


}

// MARK: - Pointer mapping (Native)
extension CanvasHandler {

  //  public var pointerHoverViewport: CGPoint? {
  //    pointer.pointerHover.value
  //  }

  /// Aka canvas local space
  //  public var pointerHoverCanvas: CGPoint? {
  //    pointerHoverMappedNative?.canvas
  //  }

  //  public var pointerHoverMapperNative: PointerHoverMapper? {
  //
  //  }

  //  public var pointerHoverMappedNative: HoverMapping? {
  //
  //    guard let pointerHoverViewport else {
  //      printMissing("pointerHoverViewport", for: "pointerHoverMappedNative")
  //      return nil
  //    }
  //
  //    guard let mapper = pointerHoverMapperNative else {
  //      printMissing("pointerHoverMapperNative", for: "pointerHoverMappedNative")
  //      return nil
  //    }
  //
  //    return mapper.map(viewportPoint: pointerHoverViewport)
  //  }

  /// Nil when the hover point is outside the canvas bounds.
  //  public var pointerHoverCanvasIfInside: CGPoint? {
  //    guard let mapped = pointerHoverMappedNative else {
  //      printMissing("pointerHoverMapped", for: "pointerHoverCanvasIfInside")
  //      return nil
  //    }
  //
  //    guard mapped.isInsideCanvas else {
  //      printDidNotSatisfy("mapped.isInsideCanvas", expectation: "true", for: "pointerHoverCanvasIfInside")
  //
  //      return nil
  //    }
  //    return mapped.canvas
  //  }
}
