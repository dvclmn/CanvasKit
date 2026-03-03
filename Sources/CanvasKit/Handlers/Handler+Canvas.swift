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
  var transform: CanvasTransformState = .initial

  var pointerTap: TapState = .init()
  var pointerDrag: DragState = .init()
  var pointerHover: HoverState = .init()

  public var geometry: CanvasGeometry?

  var zoomRange: ClosedRange<Double>?
  var zoomFocusResolver: ZoomFocusResolver = .latchedPointerOrViewportCentre

  var activeDragType: DragBehavior = .none

  public init() {}
}

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

  public var zoomClamped: Double {
    guard let zoomRange else { return zoomGesture.value }
    return zoomGesture.zoom(clampedTo: zoomRange)
  }

  public var pan: CGSize { panGesture.pan }

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

//  public func updateViewportRect(_ rect: CGRect) {
//    geometry.viewportRect = rect
//  }

//  public func updateCanvasSize(_ size: CGSize) {
//    geometry.canvasSize = size
//  }
}
