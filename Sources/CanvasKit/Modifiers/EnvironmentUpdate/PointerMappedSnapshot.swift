//
//  CanvasSnapshot.swift
//  CanvasKit
//
//  Created by Dave Coleman on 17/3/2026.
//

private import CoreTools
import SwiftUI
private import ViewTools

/// Computed from `CanvasHandler` state and geometry.
/// Holds mapped, consumer-ready values
struct PointerMappedSnapshot: Sendable {
  //  let pointer: PointerState<CanvasSpace>

  let tap: Point<CanvasSpace>?
  let hover: Point<CanvasSpace>?
  
  // This is the point where an internal PointerDragSnapshot
  // is mapped and becomes a publicly consumed CanvasDragEvent
  let drag: CanvasDragEvent?

  let isInsideCanvas: Bool
}

extension PointerMappedSnapshot {
  static func createMapped(
    mapper: CoordinateSpaceMapper,
    pointerState: PointerState<ViewportSpace>,
  ) -> Self? {
    let tapMapped = pointerState.tap.map { mapper.canvasPoint(from: $0) }
    let hoverMapped = pointerState.hover.map { mapper.canvasPoint(from: $0) }
    let dragMapped = pointerState.latestDrag.map {
      CanvasDragEvent(
        event: $0,
        mapper: mapper,
      )
    }
    //    let dragMapped = pointerState.drag.map { mapper.canvasRect(from: $0) }
    let isInside = hoverMapped.map { mapper.isInsideCanvas($0) } ?? false

    return .init(
      tap: tapMapped,
      hover: hoverMapped,
      drag: dragMapped,
      isInsideCanvas: isInside,
    )
  }

}
