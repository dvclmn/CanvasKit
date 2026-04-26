//
//  SnapshotModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//


import InputPrimitives
import SwiftUI

struct CanvasSnapshotModifier: ViewModifier {
  @Environment(\.zoomRange) private var zoomRange
  let state: CanvasState
  let pointer: PointerState
  let phase: InteractionPhase

  func body(content: Content) -> some View {
    content
//      .environment(\.zoomLevel, snapshot?.zoom ?? 1.0)
//      .environment(\.panOffset, snapshot?.pan.cgSize ?? .zero)
//      .environment(\.rotation, snapshot?.rotation ?? .zero)

      .environment(\.pointerTap, snapshot?.pointerTap)
      .environment(\.pointerDrag, snapshot?.pointerDrag)
      .environment(\.pointerHover, snapshot?.pointerHover)

      .environment(\.interactionPhase, snapshot?.phase ?? .none)
  }
}

extension CanvasSnapshotModifier {
  private var snapshot: CanvasSnapshot? {

    guard let mapper = state.mapper(zoomRange: zoomRange) else { return nil }

    let tapMapped = pointer.tap.map { mapper.canvasPoint(from: $0) }
    let hoverMapped = pointer.hover.map { mapper.canvasPoint(from: $0) }
    let rectMapped = pointer.drag.map { mapper.canvasRect(from: $0) }
    let isInside = hoverMapped.map { mapper.isInsideCanvas($0) } ?? false

    return CanvasSnapshot(
      zoom: state.transform.scale,
      pan: state.transform.translation,
      rotation: state.transform.rotation,
      pointerTap: tapMapped,
      pointerDrag: rectMapped,
      pointerHover: hoverMapped,
      isPointerInsideCanvas: isInside,
      phase: phase,
    )
  }
}
