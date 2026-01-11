//
//  ResizeDragModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 3/8/2025.
//


import BasePrimitives
import SwiftUI

struct ResizeDragModifier: ViewModifier {
  @Environment(\.isDebugMode) private var isDebugMode
  @Environment(\.canvasSize) private var canvasSize

  @Binding var store: ResizeHandler
  let draggedPoint: UnitPoint

  func body(content: Content) -> some View {
    content.gesture(dragGesture)
  }
}
extension ResizeDragModifier {
  private var dragGesture: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        if store.startCanvasSize == nil {
          store.startCanvasSize = canvasSize
        }

        if store.draggedResizePoint == nil {
          store.draggedResizePoint = GridBoundaryPoint(
            fromUnitPoint: draggedPoint
          )
        }

        if let start = store.startCanvasSize {
          let adjustedDelta = value.translation * draggedPoint.resizeDirection
          let newSize = CGSize(
            width: max(1, start.width + adjustedDelta.width),
            height: max(1, start.height + adjustedDelta.height)
          )
          store.transientCanvasSize = newSize

          store.triggerDidChangeResize(GridBoundaryPoint(fromUnitPoint: draggedPoint), newSize)
        }
      }
      .onEnded { _ in

        if let finalSize = store.transientCanvasSize {
          store.triggerDidEndResize(GridBoundaryPoint(fromUnitPoint: draggedPoint), finalSize)
        }

        /// Transient size is only required *during* an active drag event
        /// Resetting back to nil now, ready for the next event
        store.startCanvasSize = nil
        store.transientCanvasSize = nil
        store.draggedResizePoint = nil
      }
  }
}

extension UnitPoint {
  var resizeDirection: CGSize {
    CGSize(
      width: x < 0.5 ? -1 : x > 0.5 ? 1 : 0,
      height: y < 0.5 ? -1 : y > 0.5 ? 1 : 0
    )
  }
}
