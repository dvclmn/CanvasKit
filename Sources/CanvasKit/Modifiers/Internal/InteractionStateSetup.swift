//
//  InteractionStateModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import BasePrimitives
import InteractionKit
import SwiftUI

/// Bundles up the necessary parts for callers to initialise state
/// outside of CanvasView. This should be placed as high up the
/// hierarchy as is needed for access.
struct InteractionStateSetupModifier: ViewModifier {
  @Environment(\.modifierKeys) private var modifierKeys
  @Environment(\.zoomRange) private var zoomRange

  @Bindable var store: CanvasHandler
  @Binding var toolHandler: ToolHandler
  let canvasSize: Size<CanvasSpace>

  func body(content: Content) -> some View {
    content
      .environment(store)

      .setSnapshotValues(store.snapshot(zoomRange: zoomRange))

      .syncEnvironment(\.activeTool, id: \.?.kind) { store.updateTool(to: $0) }
      .syncEnvironment(\.modifierKeys) { store.updateModifiers(to: $0) }

      .environment(\.activeTool, toolHandler.effectiveTool)
      .environment(\.pointerStyle, store.pointerStyle)
  }
}
