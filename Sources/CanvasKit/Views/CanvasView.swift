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

  /// Populated when user wishes to handle their own transform state
  private let externalTransform: Binding<TransformState>?

  /// Internal-only source of truth for transform state. If user passes in state,
  /// it is passed to this. If not, this gets a default initial value
  @State private var localTransform: TransformState

  /// If the user doesn't need Tool functionality, this just stays `nil`
  /// CanvasKit doesn't require tools be used, it's opt-in
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

  public var body: some View {

    CanvasCoreView(
      canvasSize: canvasSize,
      transform: $localTransform,
      content: content,
    )
    .debugTextOverlay(alignment: .bottomTrailing) {
      if let toolHandler {
        Indented("Tool") {
          Labeled("Tool (from ToolHandler)", value: toolHandler.wrappedValue.effectiveTool.name)
          Labeled("Tool (from CanvasHandler)", value: store.activeTool?.name)
        }
      } else {
        "Tools not available"
      }

      Indented("Transform") {
        Labeled("Internal", value: localTransform.description)
        Labeled("External", value: externalTransform?.wrappedValue.description)
      }
    }
    .environment(store)

    .setSnapshotValues(
      store.snapshot(
        zoomRange: zoomRange,
        transform: localTransform,
      )
    )
    //      .setSnapshotValues(store.snapshot(zoomRange: zoomRange))

    .onEnvironmentChange(\.activeTool, id: \.?.kind) { store.updateTool(to: $0) }
    .onEnvironmentChange(\.modifierKeys) { store.updateModifiers(to: $0) }
    .task(id: toolHandler != nil) { store.updateAreToolsInUse(to: toolHandler != nil) }

    .environment(\.activeTool, toolHandler?.wrappedValue.effectiveTool)
    .environment(\.pointerStyle, pointerStyle)
    .pointerStyleCompatible(pointerStyle)

    .onChange(of: localTransform) { _, newValue in
      guard externalTransform != nil else { return }
      self.externalTransform?.wrappedValue = newValue
    }

    .onChange(of: externalTransform?.wrappedValue) { _, newValue in
      guard let newValue else { return }
      localTransform = newValue
    }
  }
}

extension CanvasView {
  private var pointerStyle: PointerStyleCompatible? {
    store.pointerStyle(transform: localTransform)
  }
  //  private var transform: TransformState {
  //    get { externalTransform?.wrappedValue ?? localTransform }
  //    nonmutating set {
  //      if let external = externalTransform {
  //        external.wrappedValue = newValue
  //      } else {
  //        localTransform = newValue
  //      }
  //    }
  //  }
}
