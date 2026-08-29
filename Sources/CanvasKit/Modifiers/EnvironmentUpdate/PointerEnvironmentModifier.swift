//
//  PointerEnvironmentModifier.swift
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
      .environment(\.pointerTapDelivery, mappedSnapshot?.tap)
      .environment(\.pointerHover, mappedSnapshot?.hover)
      .environment(\.canvasDragDelivery, mappedSnapshot?.drag)
  }
}

extension PointerEnvironmentModifier {
  private var mappedSnapshot: PointerMappedSnapshot? {
    guard let mapper = store.coordinateSpaceMapper(in: explicitCanvasSize) else { return nil }
    return .createMapped(
      mapper: mapper,
      pointerState: store.pointer,
    )
  }
}
