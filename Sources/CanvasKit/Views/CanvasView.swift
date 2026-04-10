//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import BasePrimitives
import InteractionKit
import SwiftUI

public struct CanvasView<Content: View>: View, CanvasAddressable {
  @Environment(\.zoomRange) private var zoomRange
  @State private var store: CanvasHandler = .init()
  let canvasSize: Size<CanvasSpace>
  @Binding var toolHandler: ToolHandler
  let content: () -> Content

  /// ToolHandler is required for now, until I implement state management better
  public init(
    size: CGSize,  // Canvas size
    toolHandler: Binding<ToolHandler>,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
    self._toolHandler = toolHandler
    self.content = content
  }

  public var body: some View {

    CanvasCoreView(canvasSize: canvasSize, content: content)
      .debugTextOverlay(alignment: .bottomTrailing) {
        Indented("Tool") {
          Labeled("Tool (from ToolHandler)", value: toolHandler.effectiveTool.name)
          Labeled("Tool (from CanvasHandler)", value: store.activeTool?.name)
        }
      }
      .environment(store)

      .setSnapshotValues(store.snapshot(zoomRange: zoomRange))

      .onEnvironmentChange(\.activeTool, id: \.?.kind) { store.updateTool(to: $0) }
      .onEnvironmentChange(\.modifierKeys) { store.updateModifiers(to: $0) }

      .environment(\.activeTool, toolHandler.effectiveTool)
      .environment(\.pointerStyle, store.pointerStyle)
  }
}
