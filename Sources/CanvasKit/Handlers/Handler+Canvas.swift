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

  /// Handles pan, zoom, rotation
  //  @available(*, deprecated, message: "Prefer `canvasState`, which is passed in from higher up in the View hierarchy, rather than owned by CanvasKit.")
  //  var transform: CanvasTransformState = .initial

  var transform: TransformState = .initial
  var pointer: PointerState = .initial
  //  var canvasState: CanvasTransformState = .initial

  //  var pointerTap: TapState = .init()
  //  var pointerDrag: DragState = .init()
  //  var pointerHover: HoverState = .init()

  /// Note: this `CanvasGeometry` value is computed in the Environment.
  /// This property can be mutated/updated from `CanvasView` to reflect
  /// the latest from the env, but cannot be mutated in the Env itself
  //  public var geometry: CanvasGeometry?

  /// The artwork bounds resolved in the viewport named coordinate space.
  /// Captured via SwiftUI anchor preferences in `CanvasCoreView`.
  var artworkFrameInViewport: CGRect?

  var zoomRange: ClosedRange<Double>?
  var zoomFocusResolver: ZoomFocusResolver = .latchedPointerOrViewportCentre

  var activeDragType: DragBehavior = .none

  public init() {}
}

// MARK: - Pointer mapping (Native)
extension CanvasHandler {

  public func canvasPoint(fromViewportPoint point: CGPoint) -> CGPoint? {
    guard let mapper = pointerHoverMapperNative else { return nil }
    return mapper.map(viewportPoint: point).canvas
  }

  public var pointerHoverViewport: CGPoint? {
    pointer.pointerHover.value
  }

  /// Aka canvas local space
  public var pointerHoverCanvas: CGPoint? {
    pointerHoverMappedNative?.canvas
  }

  public var pointerHoverMapperNative: PointerHoverMapper? {
    guard let artworkFrameInViewport, let canvasSize = geometry?.canvasSize else {
      return nil
    }
    return PointerHoverMapper(
      artworkFrameInViewport: artworkFrameInViewport,
      canvasSize: canvasSize,
      zoom: zoomClamped
    )
  }

  public var pointerHoverMappedNative: HoverMapping? {

    guard let pointerHoverViewport else {
      printMissing("pointerHoverViewport", for: "pointerHoverMappedNative")
      return nil
    }

    guard let mapper = pointerHoverMapperNative else {
      printMissing("pointerHoverMapperNative", for: "pointerHoverMappedNative")
      return nil
    }

    return mapper.map(viewportPoint: pointerHoverViewport)
  }

  /// Nil when the hover point is outside the canvas bounds.
  public var pointerHoverCanvasIfInside: CGPoint? {
    guard let mapped = pointerHoverMappedNative else {
      printMissing("pointerHoverMapped", for: "pointerHoverCanvasIfInside")
      return nil
    }

    guard mapped.isInsideCanvas else {
      printDidNotSatisfy("mapped.isInsideCanvas", expectation: "true", for: "pointerHoverCanvasIfInside")

      return nil
    }
    return mapped.canvas
  }
}

extension CanvasHandler {

  var zoomClamped: CGFloat { transform.zoomState.zoom.clampedIfNeeded(to: zoomRange) }

  @MainActor
  public func dragRectBinding() -> Binding<CGRect?> {
    return switch activeDragType {
      case .marquee:
        Binding {
          self.pointer.pointerDrag.value
        } set: {
          self.pointer.pointerDrag.value = $0
        }

      case .continuous:
        Binding {
          self.transform.panState.pan.toCGRectZeroOrigin
        } set: {
          self.transform.panState.update($0?.size ?? .zero, phase: .changed)
        }

      case .none:
        .constant(nil)

    }
  }
}
