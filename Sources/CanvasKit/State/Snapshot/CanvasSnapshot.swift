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
struct CanvasSnapshot: Sendable {

  let transform: TransformSnapshot
  let pointer: PointerSnapshot

  /// Phase of any in-progress gesture
  let phase: InteractionPhase

  init(
    transform: TransformSnapshot,
    pointer: PointerSnapshot,
    phase: InteractionPhase = .none,
  ) {
    self.transform = transform
    self.pointer = pointer
    self.phase = phase
  }

  init(
    zoom: Double,
    pan: Size<ScreenSpace>,
    rotation: Angle,
    pointerTap: Point<CanvasSpace>? = nil,
    pointerDrag: Rect<CanvasSpace>? = nil,
    pointerHover: Point<CanvasSpace>? = nil,
    isPointerInsideCanvas: Bool = false,
    phase: InteractionPhase = .none,
  ) {
    self.init(
      transform: .init(
        translation: pan,
        scale: zoom,
        rotation: rotation,
      ),
      pointer: .init(
        tap: pointerTap,
        drag: pointerDrag,
        hover: pointerHover,
        isInsideCanvas: isPointerInsideCanvas,
      ),
      phase: phase,
    )
  }
}

//extension CanvasSnapshot {
//  static func transformSnapshot(
//    from state: CanvasState,
//    zoomRange: ClosedRange<Double>,
//  ) -> Self? {
//    guard let mapper = state.mapper(zoomRange: zoomRange) else { return nil }
//    return CanvasSnapshot(
//      zoom: state.transform.scale,
//      pan: state.transform.translation,
//      rotation: state.transform.rotation,
//    )
//  }
//
//  static func pointerSnapshot(
//    from state: CanvasState,
//    zoomRange: ClosedRange<Double>,
//  ) -> Self? {
//    guard let mapper = state.mapper(zoomRange: zoomRange) else { return nil }
//    return CanvasSnapshot(
//      zoom: state.transform.scale,
//      pan: state.transform.translation,
//      rotation: state.transform.rotation,
//    )
//  }
//}
