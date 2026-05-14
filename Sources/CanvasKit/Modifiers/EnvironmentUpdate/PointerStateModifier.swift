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
  //  @Environment(\.canvasSize) private var canvasSize

  let explicitCanvasSize: Size<CanvasSpace>?
  //  let resolvedSize: Size<CanvasSpace>
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
    guard let frame = store.artworkFrame,
      let size = store.resolvedCanvasSize(for: explicitCanvasSize)
    else { return nil }
    return .init(frame: frame, canvasSize: size)
  }

  private var snapshot: PointerMappedSnapshot? {
    guard let mapper else { return nil }
    return .createMapped(
      mapper: mapper,
      pointerState: store.pointer,
    )
  }
}
