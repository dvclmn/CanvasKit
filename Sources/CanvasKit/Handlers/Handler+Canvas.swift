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

  var transform: TransformState = .initial
  var pointer: PointerState = .initial

  /// The artwork bounds resolved in the viewport named coordinate space.
  /// Captured via SwiftUI anchor preferences in `CanvasCoreView`.
  //  var artworkFrameInViewport: CGRect?

  var zoomRange: ClosedRange<Double>?
  var zoomFocusResolver: ZoomFocusResolver = .latchedPointerOrViewportCentre

  var activeDragType: DragBehavior = .none

  public init() {}
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
