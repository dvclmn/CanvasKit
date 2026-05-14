//
//  PointerStateEnvironmentModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//


import InputPrimitives
import SwiftUI

struct PointerStateEnvironmentModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.canvasSize) private var canvasSize

  func body(content: Content) -> some View {
    content
      .environment(\.canvasCoordinateSpaceMapper, mapper)
      .environment(\.pointerTap, snapshot?.pointer.tap)
      .environment(\.pointerDrag, snapshot?.pointer.drag)
      .environment(\.pointerHover, snapshot?.pointer.hover)
  }
}

extension PointerStateEnvironmentModifier {
  private var mapper: CoordinateSpaceMapper? {
    guard let frame = store.artworkFrame, let canvasSize else { return nil }
    return .init(frame: frame, canvasSize: canvasSize)
  }

  private var snapshot: PointerMappedSnapshot? {
    guard let mapper else { return nil }
    return .createMapped(
      mapper: mapper,
      pointerState: store.pointer,
    )
  }
}
