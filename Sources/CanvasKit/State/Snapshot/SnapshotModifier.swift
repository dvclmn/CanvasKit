//
//  SnapshotModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

import SwiftUI
import BasePrimitives

struct CanvasSnapshotModifier: ViewModifier {
  @Environment(\.zoomRange) private var zoomRange
//  let snapshot: CanvasSnapshot?
  let mapper: CoordinateSpaceMapper
  let transform: TransformState
  let pointer: PointerState
  
  func body(content: Content) -> some View {
    content
      .environment(\.zoomLevel, snapshot?.zoom ?? 1.0)
      .environment(\.panOffset, snapshot?.pan.cgSize ?? .zero)
      .environment(\.rotation, snapshot?.rotation ?? .zero)

      .environment(\.pointerTap, snapshot?.pointerTap)
      .environment(\.pointerDrag, snapshot?.pointerDrag)
      .environment(\.pointerHover, snapshot?.pointerHover)

      .environment(\.artworkFrameInViewport, snapshot?.artworkFrame)
      .environment(\.interactionPhase, snapshot?.phase ?? .none)
  }
}

extension CanvasSnapshotModifier {
  private func snapshot(
//    zoomRange: ClosedRange<Double>?,
//    transform: TransformState,
//    pointer: PointerState,
    phase: InteractionPhase,
  ) -> CanvasSnapshot? {
    
    guard let artworkFrame else { return nil }
    
    /// Raw zoom for snapshot, clamped zoom for mapper
    let zoomRaw = transform.scale
    let zoomClamped = zoomRaw.clampedIfNeeded(to: zoomRange)
    
    let mapper = CoordinateSpaceMapper(
      artworkFrame: artworkFrame,
      zoomClamped: zoomClamped,
    )
    
    let tapMapped = pointer.tap.map { mapper.canvasPoint(from: $0) }
    let hoverMapped = pointer.hover.map { mapper.canvasPoint(from: $0) }
    let rectMapped = pointer.drag.map { mapper.canvasRect(from: $0) }
    let isInside = hoverMapped.map { mapper.isInsideCanvas($0) } ?? false
    
    return CanvasSnapshot(
      zoom: zoomRaw,
      pan: transform.translation,
      rotation: transform.rotation,
      artworkFrame: artworkFrame,
      pointerTap: tapMapped,
      pointerDrag: rectMapped,
      pointerHover: hoverMapped,
      isPointerInsideCanvas: isInside,
      phase: phase,
    )
  }
}

extension View {
  func setSnapshotValues(_ snapshot: CanvasSnapshot?) -> some View {
    self.modifier(CanvasSnapshotModifier(snapshot: snapshot))
  }
}
