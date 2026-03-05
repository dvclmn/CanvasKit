//
//  Handler+CanvasGesture.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/6/2025.
//

import CoreTools
import GestureKit
import SwiftUI

@Observable
public final class CanvasHandler {
  
  /// Handles pan, zoom, rotation
  var transform: CanvasTransformState = .initial

  var pointerTap: TapState = .init()
  var pointerDrag: DragState = .init()
  var pointerHover: HoverState = .init()

  /// Note: this `CanvasGeometry` value is computed in the Environment.
  /// This property can be mutated/updated from `CanvasView` to reflect
  /// the latest from the env, but cannot be mutated in the Env itself
  public var geometry: CanvasGeometry?

  var zoomRange: ClosedRange<Double>?
  var zoomFocusResolver: ZoomFocusResolver = .latchedPointerOrViewportCentre

  var activeDragType: DragBehavior = .none

  public init() {}
}

/// Basic convenience for `CanvasTransformState` access
extension CanvasHandler {

  var panGesture: PanState {
    get { transform.pan }
    set { transform.pan = newValue }
  }

  var zoomGesture: ZoomState {
    get { transform.zoom }
    set { transform.zoom = newValue }
  }

  var rotateGesture: RotateState {
    get { transform.rotation }
    set { transform.rotation = newValue }
  }

  public var isPerformingGesture: Bool {
    transform.isPerformingGesture
  }
}

extension CanvasHandler {

  var zoomClamped: CGFloat { zoomGesture.value.clampedIfNeeded(to: zoomRange) }

  @MainActor
  public func dragRectBinding() -> Binding<CGRect?> {
    return switch activeDragType {
      case .marquee:
        Binding {
          self.pointerDrag.value
        } set: {
          self.pointerDrag.value = $0
        }

      case .continuous:
        Binding {
          self.panGesture.pan.toCGRectZeroOrigin
        } set: {
          self.panGesture.update($0?.size ?? .zero, phase: .changed)
        }

      case .none:
        .constant(nil)

    }
  }
}
