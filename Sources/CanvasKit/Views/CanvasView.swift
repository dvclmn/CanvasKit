//
//  CanvasView.swift
//  Lilypad
//
//  Created by Dave Coleman on 24/6/2025.
//

import CoreUtilities
import InputPrimitives
import SwiftUI

public struct CanvasView<Content: View>: View, CanvasAddressable {
  //  @Environment(\.canvasClipping) private var canvasClipping
  @State private var store: CanvasHandler

  /// Populated when user wishes to handle their own transform state
  private let externalTransform: Binding<TransformState>?
  private let externalCoordinateSpaceMapper: Binding<CoordinateSpaceMapper?>?

  /// Populated when user wishes to handle their own tool configuration state.
  private let externalToolConfiguration: Binding<ToolConfiguration>?

  let explicitCanvasSize: Size<CanvasSpace>?
  //  let canvasSize: Size<CanvasSpace>
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
      .updatePointerEnvironment(in: )

      /// In cases where transform state is owned externally,
      /// ensures both local and external are kept in sync
      .bindModel(
        debounce: .noDebounce,
        $store.currentTransform,
        to: externalTransform,
      )
      .bindModel(
        debounce: .noDebounce,
        $store.toolHandler.configuration,
        to: externalToolConfiguration,
      )
      .syncValue(coordinateSpaceMapper, to: externalCoordinateSpaceMapper)
      .onDisappear {
        externalCoordinateSpaceMapper?.wrappedValue = nil
      }

      .modifier(CanvasToolKeyboardModifier(toolHandler: $store.toolHandler))
      .modifierKeys { store.updateModifiers($0) }

      //      .environment(\.canvasSize, canvasSize)
      .environment(\.activeInteraction, store.activeInteraction)
      .environment(store)

      .onDisappear {
        externalCoordinateSpaceMapper?.wrappedValue = nil
      }

    //      .debugTextOverlay(isEnabled: true)

  }
}

// MARK: - Inits
extension CanvasView {

  /// Externally-owned transform state and Tools configuration.
  public init(
    size: CGSize? = nil,
    transform: Binding<TransformState>? = nil,
    coordinateSpaceMapper: Binding<CoordinateSpaceMapper?>? = nil,
    toolConfiguration: Binding<ToolConfiguration>? = nil,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    let initialToolConfiguration = toolConfiguration?.wrappedValue ?? .default
    self.explicitCanvasSize = size.map { Size<CanvasSpace>(fromCGSize: $0) }
    self.externalTransform = transform
    self.externalCoordinateSpaceMapper = coordinateSpaceMapper
    self.externalToolConfiguration = toolConfiguration
    self._store = State(initialValue: .init(toolConfiguration: initialToolConfiguration))
    self.content = content
  }
}

extension CanvasView {
  private var coordinateSpaceMapper: CoordinateSpaceMapper? {
    guard let frame = store.artworkFrame else { return nil }
    return .init(frame: frame, canvasSize: canvasSize)
  }
}
