//
//  PointerStateEnvironmentModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

private import CoreTools
import SwiftUI

struct PointerEnvironmentModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.explicitCanvasSize) private var explicitCanvasSize

  func body(content: Content) -> some View {
    content
      .environment(\.pointerTap, snapshot?.pointer.tap)
      //      .environment(\.pointerDrag, snapshot?.pointer.drag)
      .environment(\.pointerHover, snapshot?.pointer.hover)
      .environment(\.canvasDragEvent, mappedDragEvent)
  }
}

extension PointerEnvironmentModifier {
  private var snapshot: PointerMappedSnapshot? {
    guard let mapper = store.coordinateSpaceMapper(in: explicitCanvasSize) else { return nil }
    return .createMapped(
      mapper: mapper,
      pointerState: store.pointer,
    )
  }

  // This is the point where an internal PointerDragSnapshot
  // is mapped and becomes a publicly consumed CanvasDragEvent
  private var mappedDragEvent: CanvasDragEvent? {
    guard let mapper = store.coordinateSpaceMapper(in: explicitCanvasSize),
      let eventSnapshot = store.pointer.latestDrag
    else { return nil }

    return .init(event: eventSnapshot, mapper: mapper)
  }
}
