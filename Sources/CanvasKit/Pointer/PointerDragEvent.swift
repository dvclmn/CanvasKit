//
//  PointerDragEvent.swift
//  CanvasKit
//
//  Created by Dave Coleman on 20/8/2026.
//

/// An ordered marquee-drag snapshot before coordinate-space mapping.
///
/// This remains internal because CanvasKit publishes marquee input only after
/// converting it into ``CanvasSpace`` as ``CanvasDragEvent``.
struct PointerDragEvent<Space>: Sendable, Equatable {
  let start: Point<Space>
  let current: Point<Space>
  let phase: InteractionPhase
}

extension PointerDragEvent {
  init?(
    payload: PointerDragPayload,
    phase: InteractionPhase,
  ) where Space == ViewportSpace {
    guard case .rect(let start, let current) = payload else { return nil }
    self.init(start: start, current: current, phase: phase)
  }

  func withPhase(_ phase: InteractionPhase) -> Self {
    .init(start: start, current: current, phase: phase)
  }
}
