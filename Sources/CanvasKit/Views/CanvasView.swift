//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import BasePrimitives
//import InteractionKit
import SwiftUI

public struct CanvasView<Content: View>: View, CanvasAddressable {
  @Environment(\.zoomRange) private var zoomRange

  @State private var store: CanvasHandler = .init()

  /// Populated when user wishes to handle their own transform state
  private let externalTransform: Binding<TransformState>?

  /// Internal-only source of truth for transform state. If user passes in state,
  /// it is passed to this. If not, this gets a default initial value.
  /// External and internal state is kept in sync via ``
  @State private var localTransform: TransformState

  /// Canvas Tool use is opt-in. If the user doesn't need tools, this stays nil
  private let toolHandler: Binding<ToolHandler>?

  let canvasSize: Size<CanvasSpace>
  let content: () -> Content

  /// Basic usage, CanvasKit manages transform state internally
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

  /// Externally-owned transform state, enabling programmatic
  /// control outside the CanvasKit view hierarchy
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

  /// Externally-owned transform state and Canvas Tool usage
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
    .pointerStyleCompatible(pointerStyle)
    
    .setSnapshotValues(
      store.snapshot(
        zoomRange: zoomRange,
        transform: localTransform,
      )
    )
    
    .onEnvironmentChange(\.modifierKeys) { store.updateModifiers(to: $0) }
    .task(id: toolHandler != nil) { store.areToolsInUse = toolHandler != nil }
    .environment(\.activeTool, toolHandler?.wrappedValue.effectiveTool)
    .environment(\.pointerStyle, pointerStyle)
    .environment(store)

    /// In cases where transform state is owned externally,
    /// ensures both local and external are kept in sync
    .bindModel(
      debounce: .noDebounce,
      $localTransform,
      to: externalTransform,
    )
  }
}

extension CanvasView {
  private var pointerStyle: PointerStyleCompatible? {
    guard let tool = toolHandler?.wrappedValue.effectiveTool else { return nil }
    return store.pointerStyle(tool: tool, transform: localTransform)
  }
}
