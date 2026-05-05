//
//  CanvasSnapshot.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import GeometryPrimitives
import InputPrimitives
import SwiftUI

/// Computed from `CanvasHandler` state and geometry.
/// Holds only already-converted/mapped, consumer-ready values
struct PointerMappedSnapshot: Sendable {
  let pointer: PointerState<CanvasSpace>
  let isInsideCanvas: Bool
}

extension PointerMappedSnapshot {
  static func createMapped(
    artworkFrame: Rect<ViewportSpace>,
    canvasSize: Size<CanvasSpace>,
    pointerState: PointerState<ViewportSpace>,
  ) -> Self? {
    let mapper = CoordinateSpaceMapper(frame: artworkFrame, canvasSize: canvasSize)

    let tapMapped = pointerState.tap.map { mapper.canvasPoint(from: $0) }
    let hoverMapped = pointerState.hover.map { mapper.canvasPoint(from: $0) }
    let dragMapped = pointerState.drag.map { mapper.canvasRect(from: $0) }
    let isInside = hoverMapped.map { mapper.isInsideCanvas($0) } ?? false

    return .init(
      pointer: .init(
        tap: tapMapped,
        hover: hoverMapped,
        drag: dragMapped,
      ),
      isInsideCanvas: isInside,
    )
  }
}

struct ActiveInteraction: Sendable {
  let kind: InteractionKind?
  let phase: InteractionPhase

  static let none: Self = .init(kind: nil, phase: .none)
}
