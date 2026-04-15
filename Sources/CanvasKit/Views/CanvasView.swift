//
//  CanvasView.swift
//  Lilypad
//
//  Created by Dave Coleman on 24/6/2025.
//

import BasePrimitives
import SwiftUI

public struct CanvasView<Content: View>: View, CanvasAddressable {
  @Environment(\.zoomRange) private var zoomRange

  @State private var store: CanvasHandler = .init()
  @State private var toolHandler: ToolHandler

  /// Populated when user wishes to handle their own transform state
  private let externalTransform: Binding<TransformState>?

  /// Internal-only source of truth for transform state. If user passes in state,
  /// it is passed to this. If not, this gets a default initial value.
  /// External and internal state is kept in sync via `bindModel`.
  @State private var localTransform: TransformState

  /// Canvas Tool use is opt-in. If the user doesn't need tools, this stays nil
  private let toolConfiguration: Binding<CanvasToolConfiguration>?

  let canvasSize: Size<CanvasSpace>
  let content: () -> Content

  public var body: some View {
    let activeTool: (any CanvasTool)? = toolConfiguration == nil ? nil : toolHandler.effectiveTool

    CanvasCoreView(
      canvasSize: canvasSize,
      transform: localTransform,
      content: content,
    )

    /// User input modifiers, `onSwipeGesture`, `onTapGesture`, etc
    .modifier(
      InteractionModifiers(
        transform: $localTransform,
        tool: activeTool,
      )
    )
    
    /// Set the resolved pointer style and add it to the Environment
    .pointerStyleCompatible(store.pointerStyle)
    .environment(\.pointerStyle, store.pointerStyle)
    .environment(store)

    /// In cases where transform state is owned externally,
    /// ensures both local and external are kept in sync
    .bindModel(
      debounce: .noDebounce,
      $localTransform,
      to: externalTransform,
    )

//    .modifier(
//      CanvasToolKeyboardModifier(
//        toolHandler: $toolHandler,
//        isEnabled: toolConfiguration != nil
//      )
//    )

    .task(id: toolConfiguration?.wrappedValue.fingerprint ?? "no-tool-configuration") {
      guard let toolConfiguration else { return }
      toolHandler = ToolHandler(configuration: toolConfiguration.wrappedValue)
    }

    .onChange(of: toolConfiguration?.wrappedValue.selectedToolKind, initial: false) { _, newValue in
      guard let newValue, toolConfiguration != nil, toolHandler.selectedToolKind != newValue else { return }
      var handler = toolHandler
      handler.setBaseTool(kind: newValue)
      toolHandler = handler
    }

    .onChange(of: toolHandler.selectedToolKind, initial: false) { _, newValue in
      guard let toolConfiguration,
        toolConfiguration.wrappedValue.selectedToolKind != newValue
      else { return }
      toolConfiguration.wrappedValue.selectedToolKind = newValue
    }
  }
}

// MARK: - Inits
extension CanvasView {

  /// Basic usage, CanvasKit manages transform state internally
  public init(
    size: CGSize,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
    self._localTransform = State(initialValue: .identity)
    self.externalTransform = nil
    self._toolHandler = State(initialValue: .init(configuration: .default))
    self.toolConfiguration = nil
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
    self._toolHandler = State(initialValue: .init(configuration: .default))
    self.toolConfiguration = nil
    self.content = content
  }

  /// Externally-owned transform state and Canvas Tool usage.
  public init(
    size: CGSize,
    transform: Binding<TransformState>,
    toolConfiguration: Binding<CanvasToolConfiguration>,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
    self._localTransform = State(initialValue: transform.wrappedValue)
    self.externalTransform = transform
    self._toolHandler = State(initialValue: .init(configuration: toolConfiguration.wrappedValue))
    self.toolConfiguration = toolConfiguration
    self.content = content
  }

  /// Externally-owned Canvas Tool configuration with internal transform state.
  public init(
    size: CGSize,
    toolConfiguration: Binding<CanvasToolConfiguration>,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
    self._localTransform = State(initialValue: .identity)
    self.externalTransform = nil
    self._toolHandler = State(initialValue: .init(configuration: toolConfiguration.wrappedValue))
    self.toolConfiguration = toolConfiguration
    self.content = content
  }

}
