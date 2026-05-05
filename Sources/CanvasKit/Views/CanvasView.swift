//
//  CanvasView.swift
//  Lilypad
//
//  Created by Dave Coleman on 24/6/2025.
//

import CoreUtilities
import GeometryPrimitives
import InputPrimitives
import SwiftUI

public struct CanvasView<Content: View>: View, CanvasAddressable {
  @State private var store: CanvasHandler

  /// Populated when user wishes to handle their own transform state
  private let externalTransform: Binding<TransformState>?

  /// Internal-only source of truth for transform state. If user passes in state,
  /// it is passed to this. If not, this gets a default initial value.
  /// External and internal state is kept in sync via `bindModel`.
  //  @State private var localTransform: TransformState

  /// Populated when user wishes to handle their own tool configuration state.
  private let externalToolConfiguration: Binding<ToolConfiguration>?

  let canvasSize: Size<CanvasSpace>
  let content: () -> Content

  public var body: some View {
    @Bindable var store = store

    CanvasCoreView(content: content)

      /// User input modifiers, `onSwipeGesture`, `onTapGesture`, etc.
      /// These wrap the canvas only, so their invisible event-capture overlays
      /// do not sit above the tool picker.
      .modifier(InteractionModifiers())

      .pointerStyleCompatible(store.pointerStyle)

      .toolPalette()

      /// Adds canvas transform and mapped pointer values to the Environment
      .updateTransformEnvironment()
      .updatePointerEnvironment()

      /// In cases where transform state is owned externally,
      /// ensures both local and external are kept in sync
      .bindModel(
        debounce: .noDebounce,
        $store.currentTransform,
        to: externalTransform,
      )

      .modifier(CanvasToolKeyboardModifier(toolHandler: $store.toolHandler))
      .modifierKeys { store.updateModifiers($0) }

      .bindModel(
        debounce: .noDebounce,
        $store.toolHandler.configuration,
        to: externalToolConfiguration,
      )

      .environment(\.canvasSize, canvasSize)
      .environment(\.activeInteraction, store.activeInteraction)
      .environment(store)

      .debugTextOverlay(isEnabled: true)

  }
}

// MARK: - Inits
extension CanvasView {

  /// Externally-owned transform state and Tools configuration.
  public init(
    size: CGSize,
    transform: Binding<TransformState>,
    toolConfiguration: Binding<ToolConfiguration>? = nil,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    let initialToolConfiguration = toolConfiguration?.wrappedValue ?? .default
    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
    self.externalTransform = transform
    self.externalToolConfiguration = toolConfiguration
    self._store = State(initialValue: .init(toolConfiguration: initialToolConfiguration))
    self.content = content
  }
}
