//
//  PointerDragSnapshot.swift
//  CanvasKit
//
//  Created by Dave Coleman on 20/8/2026.
//

/// An ordered marquee-drag snapshot before coordinate-space mapping.
///
/// This remains internal because CanvasKit publishes marquee input only after
/// converting it into ``CanvasSpace`` as ``CanvasDragEvent``. `deliveryID`
/// identifies the physical lifecycle update independently of that mapping.
struct PointerDragSnapshot<Space>: Sendable, Equatable {
  let start: Point<Space>
  let current: Point<Space>
  let phase: InteractionPhase
  let deliveryID: PointerEventDeliveryID
}

extension PointerDragSnapshot {
  init?(
    payload: PointerDragPayload,
    phase: InteractionPhase,
    deliveryID: PointerEventDeliveryID,
  ) where Space == ViewportSpace {
    guard case .rect(let start, let current) = payload else { return nil }
    self.init(
      start: start,
      current: current,
      phase: phase,
      deliveryID: deliveryID,
    )
  }

  func withPhase(
    _ phase: InteractionPhase,
    deliveryID: PointerEventDeliveryID,
  ) -> Self {
    .init(
      start: start,
      current: current,
      phase: phase,
      deliveryID: deliveryID,
    )
  }
}
