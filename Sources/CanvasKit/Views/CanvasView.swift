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
      .modifier(
        InteractionStateSetupModifier(
          store: store,
          toolHandler: $toolHandler,
          canvasSize: canvasSize,
        )
      )
  }
}
