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
  @Environment(\.isShowingToolPicker) private var isShowingToolPicker
  @Environment(\.toolPickerAlignment) private var toolPickerAlignment
  @State private var store: CanvasHandler

  /// Populated when user wishes to handle their own transform state
  private let externalTransform: Binding<TransformState>?

  /// Internal-only source of truth for transform state. If user passes in state,
  /// it is passed to this. If not, this gets a default initial value.
  /// External and internal state is kept in sync via `bindModel`.
  @State private var localTransform: TransformState

  /// Populated when user wishes to handle their own tool configuration state.
  private let externalToolConfiguration: Binding<ToolConfiguration>?

  let canvasSize: Size<CanvasSpace>
  let content: () -> Content

  public var body: some View {
    @Bindable var store = store

    CanvasCoreView(
      canvasSize: canvasSize,
      transform: $localTransform,
      content: content,
    )

    /// User input modifiers, `onSwipeGesture`, `onTapGesture`, etc.
    /// These wrap the canvas only, so their invisible event-capture overlays
    /// do not sit above the tool picker.
    .modifier(
      InteractionModifiers(transform: $localTransform)
    )

    .overlay(alignment: toolPickerAlignment) {
      if isShowingToolPicker {
        ToolsView(toolConfiguration: $store.toolHandler.configuration)
      }
    }

    /// Publishes current canvas transform values to the Environment
    .canvasTransformEnvironment(localTransform)

    /// Adds mapped pointer values and interaction phase to the Environment
    .modifier(
      CanvasSnapshotModifier(
        transform: localTransform,
        artworkFrame: store.artworkFrame,
        canvasSize: canvasSize,
        pointer: store.pointer,
        phase: store.interactionContext?.phase ?? .none,
      )
    )

//    .debugText {
//      Labeled("Ext. Tool Config", value: externalToolConfiguration?.wrappedValue)
//      "\n"
//      Divider()
//      Labeled("Runtime Tool Config", value: store.toolHandler.configuration)
//    }
//    //    .modifier(DebugOverlayModifier(isEnabled: false))
//    .debugTextOverlay(isEnabled: true)

    /// In cases where transform state is owned externally,
    /// ensures both local and external are kept in sync
    .bindModel(
      debounce: .noDebounce,
      $localTransform,
      to: externalTransform,
    )

    /// Wonder if I just keep this here, even if the user is already listening
    /// for modifier keys some other way elsewhere? Or, whether I should be
    /// allowing passing in own state for modifiers.
    .modifierKeys { keys in
      store.updateModifiers(keys)
    }

    .modifier(CanvasToolKeyboardModifier(toolHandler: $store.toolHandler))

    .bindModel(
      debounce: .noDebounce,
      $store.toolHandler.configuration,
      to: externalToolConfiguration,
    )

    /// Set the resolved pointer style and add it to the Environment
    .pointerStyleCompatible(store.pointerStyle)
    .environment(\.pointerStyle, store.pointerStyle)
    .environment(store)

  }
}

// MARK: - Inits
extension CanvasView {

  // MARK: No Tool use
  /// Basic usage, CanvasKit manages transform state internally. No Tool use.
  //  public init(
  //    size: CGSize,
  //    @ViewBuilder content: @escaping () -> Content,
  //  ) {
  //    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
  //    self._localTransform = State(initialValue: .identity)
  //    self.externalTransform = nil
  //    self._toolHandler = State(initialValue: .init(configuration: .default))
  //    self.toolConfiguration = nil
  //    self.content = content
  //  }
  //
  //  /// Externally-owned transform state, enabling programmatic
  //  /// control outside the CanvasKit view hierarchy. No Tool use.
  //  public init(
  //    size: CGSize,
  //    transform: Binding<TransformState>,
  //    @ViewBuilder content: @escaping () -> Content,
  //  ) {
  //    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
  //    self._localTransform = State(initialValue: transform.wrappedValue)
  //    self.externalTransform = transform
  //    self._toolHandler = State(initialValue: .init(configuration: .default))
  //    self.toolConfiguration = nil
  //    self.content = content
  //  }
  //
  //  // MARK: Tool use Enabled
  //  /// Internally owned transform state. Externally-owned Canvas Tool configuration, enabling Tool use.
  //  public init(
  //    size: CGSize,
  //    toolConfiguration: Binding<ToolConfiguration>,
  //    @ViewBuilder content: @escaping () -> Content,
  //  ) {
  //    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
  //    self._localTransform = State(initialValue: .identity)
  //    self.externalTransform = nil
  //    self._toolHandler = State(initialValue: .init(configuration: toolConfiguration.wrappedValue))
  //    self.toolConfiguration = toolConfiguration
  //    self.content = content
  //  }

  /// Externally-owned transform state and Canvas Tool usage.
  public init(
    size: CGSize,
    transform: Binding<TransformState>,
    toolConfiguration: Binding<ToolConfiguration>? = nil,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    let initialToolConfiguration = toolConfiguration?.wrappedValue ?? .default
    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
    self._localTransform = State(initialValue: transform.wrappedValue)
    self.externalTransform = transform
    self.externalToolConfiguration = toolConfiguration
    self._store = State(initialValue: .init(toolConfiguration: initialToolConfiguration))
    self.content = content
  }
}
