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

  //  @State private var transform: TransformState
  // Always a binding internally
  @Binding private var transform: TransformState

  // Only used when we "self-own"
  @State private var internalTransform: TransformState = .identity

  let canvasSize: Size<CanvasSpace>
  @Binding var toolHandler: ToolHandler
  let content: () -> Content

  /// ToolHandler is required for now, until I implement state management better
  //  public init(
  //    size: CGSize,  // Canvas size
  //    transform: Binding<TransformState> = .constant(.identity),
  //    toolHandler: Binding<ToolHandler> = .constant(.init()),
  //    @ViewBuilder content: @escaping () -> Content,
  //  ) {
  //    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
  //    self._transform = transform
  //    self._toolHandler = toolHandler
  //    self.content = content
  //  }

  public init(

    size canvasSize: Size<CanvasSpace>,
    transform: Binding<TransformState>,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = canvasSize
    self._transform = transform
    self._toolHandler = .constant(.init())
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
      .pointerStyleCompatible(store.)
  }
}
