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

    .environment(store)

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
    .pointerStyleCompatible(pointerStyle)

    /// In cases where transform state is handled externally,
    /// ensures both local and external are kept in sync
    .bindModel(
      debounce: .noDebounce,
      $localTransform,
      to: externalTransform
    )
  }
}

extension CanvasView {
  private var pointerStyle: PointerStyleCompatible? {
    guard let tool = toolHandler?.wrappedValue.effectiveTool else { return nil }
    return store.pointerStyle(tool: tool, transform: localTransform)
  }
}
