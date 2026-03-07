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
  public var pointerHoverMapperNative: NativePointerHoverHandler? {
    guard let artworkFrameInViewport, let canvasSize = geometry?.canvasSize else {
      return nil
    }
    return NativePointerHoverHandler(
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
