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
  //  let phase: InteractionPhase
  //  let activeInteraction: ActiveInteraction?
  let interaction: ActiveInteraction
  //  let context: InteractionContext?

  init(
    transform: TransformSnapshot,
    pointer: PointerSnapshot,
    interaction: ActiveInteraction,
      //    context: InteractionContext? = nil,
      //    interaction: InteractionKind? = nil,
      //    phase: InteractionPhase = .none,
  ) {
    self.transform = transform
    self.pointer = pointer
    self.interaction = interaction
    //    self.phase = phase

    //    self.activeInteraction = .init(kind: interaction, phase: phase)
  }

  //  init(
  //    zoom: Double,
  //    pan: Size<ViewportSpace>,
  //    rotation: Angle,
  //    pointerTap: Point<CanvasSpace>? = nil,
  //    pointerDrag: Rect<CanvasSpace>? = nil,
  //    pointerHover: Point<CanvasSpace>? = nil,
  //    isPointerInsideCanvas: Bool = false,
  //    phase: InteractionPhase = .none,
  //  ) {
  //    self.init(
  //      transform: .init(
  //        translation: pan,
  //        scale: zoom,
  //        rotation: rotation,
  //      ),
  //      pointer: .init(
  //        tap: pointerTap,
  //        drag: pointerDrag,
  //        hover: pointerHover,
  //        isInsideCanvas: isPointerInsideCanvas,
  //      ),
  //      phase: phase,
  //    )
  //  }
}

extension CanvasSnapshot {
  static func createMapped(
    artworkFrame: Rect<ViewportSpace>?,
    canvasSize: Size<CanvasSpace>,
    transform: TransformState,
    pointerState: PointerState,
    context: InteractionContext?
  ) -> Self? {
    guard let artworkFrame else { return nil }
    let mapper = CoordinateSpaceMapper(frame: artworkFrame, canvasSize: canvasSize)
    
    let tapMapped = pointerState.tap.map { mapper.canvasPoint(from: $0) }
    let hoverMapped = pointerState.hover.map { mapper.canvasPoint(from: $0) }
    let rectMapped = pointerState.drag.map { mapper.canvasRect(from: $0) }
    let isInside = hoverMapped.map { mapper.isInsideCanvas($0) } ?? false
    
    return CanvasSnapshot(
      transform: .init(transform: store.currentTransform),
      pointer: .init(
        tap: tapMapped,
        drag: rectMapped,
        hover: hoverMapped,
        isInsideCanvas: isInside,
      ),
      
      //      phase: phase,
    )
  }
}

struct ActiveInteraction: Sendable {
  let kind: InteractionKind?
  let phase: InteractionPhase

  static let none: Self = .init(kind: nil, phase: .none)
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
