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
///
/// Note to self: I removed this type at one point, thinking it wasn't
/// doing anything useful. But soon realised its really helpful for
/// centralising fully mapped state unambiguously, well worth keeping.
struct CanvasSnapshot: Sendable {

  let transform: TransformSnapshot
  
  /// ## Pointer state
  let pointerTap: Point<CanvasSpace>?
  let pointerDrag: Rect<CanvasSpace>?
  let pointerHover: Point<CanvasSpace>?
  let isPointerInsideCanvas: Bool

  /// Phase of any in-progress gesture
  let phase: InteractionPhase

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
    self.zoom = zoom
    self.pan = pan
    self.rotation = rotation
    self.pointerTap = pointerTap
    self.pointerDrag = pointerDrag
    self.pointerHover = pointerHover
    self.isPointerInsideCanvas = isPointerInsideCanvas
    self.phase = phase
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
