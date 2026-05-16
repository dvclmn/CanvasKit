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
  @State private var store: CanvasHandler

  /// Populated when user wishes to handle their own transform state
  private let externalTransform: Binding<TransformState>?
  private let externalCoordinateSpaceMapper: Binding<CoordinateSpaceMapper?>?

  /// Used only if a user passes in a canvas size value.
  /// Otherwise size is measured internally
  let explicitCanvasSize: Size<CanvasSpace>?
  let content: () -> Content
  
  /// Main initialiser
  public init(
    size: CGSize? = nil,
    transform: Binding<TransformState>? = nil,
    coordinateSpaceMapper: Binding<CoordinateSpaceMapper?>? = nil,
    toolConfiguration: ToolConfiguration? = nil,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.explicitCanvasSize = size.map { Size<CanvasSpace>(fromCGSize: $0) }
    self.externalTransform = transform
    self.externalCoordinateSpaceMapper = coordinateSpaceMapper
    self._store = State(
      initialValue: .init(
        toolConfiguration: toolConfiguration
      )
    )
    self.content = content
  }

  public var body: some View {
    @Bindable var store = store

    CanvasCoreView(content: content)

      /// User input modifiers, `onSwipeGesture`, `onTapGesture`, etc.
      /// These wrap the canvas only, so their invisible event-capture overlays
      /// do not sit above the tool picker.
      .modifier(InteractionModifiers())
      .pointerStyleCompatible(store.pointerStyle)
    
      .modifier(ToolsPaletteViewModifier())

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

      .syncValue(
        store.coordinateSpaceMapper(in: explicitCanvasSize),
        to: externalCoordinateSpaceMapper,
      )

      .onDisappear {
        externalCoordinateSpaceMapper?.wrappedValue = nil
      }

      .modifier(CanvasToolKeyboardModifier(toolHandler: $store.toolHandler))
      .modifierKeys { store.updateModifiers($0) }

      .environment(\.canvasCoordinateSpaceMapper, store.coordinateSpaceMapper(in: explicitCanvasSize))
      .environment(\.activeInteraction, store.activeInteraction)
      .environment(store)

      .onDisappear {
        externalCoordinateSpaceMapper?.wrappedValue = nil
      }

  }
}

// MARK: - Inits
extension CanvasView {

}
