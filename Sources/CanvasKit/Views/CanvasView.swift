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

  private let externalTransform: Binding<TransformState>?
  @State private var localTransform: TransformState
  private let toolHandler: Binding<ToolHandler>?
  let canvasSize: Size<CanvasSpace>
  let content: () -> Content

  // MARK: - Simple init — CanvasView owns everything
  public init(
    size: CGSize,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
    self._localTransform = State(initialValue: .identity)
    self.externalTransform = nil
    self.toolHandler = nil
    self.content = content
  }

  // MARK: - External transform
  public init(
    size: CGSize,
    transform: Binding<TransformState>,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
    self._localTransform = State(initialValue: transform.wrappedValue)
    self.externalTransform = transform
    self.toolHandler = nil
    self.content = content
  }

  // MARK: - Full external control
  public init(
    size: CGSize,
    transform: Binding<TransformState>,
    toolHandler: Binding<ToolHandler>,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
    self._localTransform = State(initialValue: transform.wrappedValue)
    self.externalTransform = transform
    self.toolHandler = toolHandler
    self.content = content
  }

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

  public var body: some View {

    CanvasCoreView(canvasSize: canvasSize, content: content)
      .debugTextOverlay(alignment: .bottomTrailing) {
        Indented("Tool") {
          Labeled("Tool (from ToolHandler)", value: toolHandler?.wrappedValue.effectiveTool.name)
          Labeled("Tool (from CanvasHandler)", value: store.activeTool?.name)
        }
      }
      .environment(store)

      .setSnapshotValues(
        store.snapshot(
          zoomRange: zoomRange,
          transform: transform,
        )
      )
      //      .setSnapshotValues(store.snapshot(zoomRange: zoomRange))

      .onEnvironmentChange(\.activeTool, id: \.?.kind) { store.updateTool(to: $0) }
      .onEnvironmentChange(\.modifierKeys) { store.updateModifiers(to: $0) }

      .environment(\.activeTool, toolHandler?.wrappedValue.effectiveTool)
      .environment(\.pointerStyle, pointerStyle)
      .pointerStyleCompatible(pointerStyle)
  }
}

extension CanvasView {
  private var pointerStyle: PointerStyleCompatible? {
    store.pointerStyle(transform: transform)
  }
  private var transform: TransformState {
    get { externalTransform?.wrappedValue ?? localTransform }
    nonmutating set {
      if let external = externalTransform {
        external.wrappedValue = newValue
      } else {
        localTransform = newValue
      }
    }
  }
}
