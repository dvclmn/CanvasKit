//
//  PointerStateEnvironmentModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

import GeometryPrimitives
import InputPrimitives
import SwiftUI

struct PointerStateEnvironmentModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.canvasSize) private var canvasSize

//  let transform: TransformState
//  let artworkFrame: Rect<ViewportSpace>?
  
//  let pointer: PointerState<>
//  let phase: InteractionPhase

  func body(content: Content) -> some View {
    content
      .environment(\.pointerTap, snapshot?.pointer.tap)
      .environment(\.pointerDrag, snapshot?.pointer.drag)
      .environment(\.pointerHover, snapshot?.pointer.hover)
//      .environment(\.interaction, snapshot?.interaction ?? .none)
//      .environment(\.interactionPhase, snapshot?.phase ?? .none)
  }
}

extension PointerStateEnvironmentModifier {
  private var snapshot: PointerMappedSnapshot? {
    guard let frame = store.artworkFrame, let canvasSize else { return nil }
    return .createMapped(
      artworkFrame: frame,
      canvasSize: canvasSize,
      pointerState: store.pointer,
    )
  }
//  private var snapshot: CanvasSnapshot? {
//    guard let artworkFrame, let canvasSize else { return nil }
//    let mapper = CoordinateSpaceMapper(frame: artworkFrame, canvasSize: canvasSize)
//
//    let tapMapped = pointer.tap.map { mapper.canvasPoint(from: $0) }
//    let hoverMapped = pointer.hover.map { mapper.canvasPoint(from: $0) }
//    let rectMapped = pointer.drag.map { mapper.canvasRect(from: $0) }
//    let isInside = hoverMapped.map { mapper.isInsideCanvas($0) } ?? false
//
//    return CanvasSnapshot(
//      transform: .init(transform: store.currentTransform),
//      pointer: .init(
//        tap: tapMapped,
//        drag: rectMapped,
//        hover: hoverMapped,
//        isInsideCanvas: isInside,
//      ),
//      
////      phase: phase,
//    )
//  }
}
