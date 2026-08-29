//
//  PointerMappedSnapshot.swift
//  CanvasKit
//
//  Created by Dave Coleman on 17/3/2026.
//

private import CoreTools
/// Consumer-ready pointer observations mapped into ``CanvasSpace``.
struct PointerMappedSnapshot: Sendable {
  let tap: PointerEventDelivery<Point<CanvasSpace>>?
  let hover: Point<CanvasSpace>?
  let drag: PointerEventDelivery<CanvasDragEvent>?
  let isInsideCanvas: Bool
}

extension PointerMappedSnapshot {
  static func createMapped(
    mapper: CoordinateSpaceMapper,
    pointerState: PointerState<ViewportSpace>,
  ) -> Self {
    let tapMapped = pointerState.tap.map {
      PointerEventDelivery(
        deliveryID: $0.deliveryID,
        value: mapper.canvasPoint(from: $0.location),
      )
    }
    let hoverMapped = pointerState.hover.map { mapper.canvasPoint(from: $0) }
    let dragMapped = pointerState.latestDrag.map {
      PointerEventDelivery(
        deliveryID: $0.deliveryID,
        value: CanvasDragEvent(
          event: $0,
          mapper: mapper,
        ),
      )
    }
    let isInside = hoverMapped.map { mapper.isInsideCanvas($0) } ?? false

    return .init(
      tap: tapMapped,
      hover: hoverMapped,
      drag: dragMapped,
      isInsideCanvas: isInside,
    )
  }
}
