//
//  CanvasView.swift
//  Lilypad
//
//  Created by Dave Coleman on 24/6/2025.
//

private import CoreTools
import SwiftUI
private import ViewTools

public struct CanvasView<Content: View>: View, CanvasAddressable {
  @State private var store: CanvasHandler

  /// Populated when the caller owns transform state externally.
  private let externalTransform: Binding<TransformState>?
  private let externalCoordinateSpaceMapper: Binding<CoordinateSpaceMapper?>?
  private let externalPointerStyle: Binding<CanvasPointerStyle?>?
  private let externalToolSelection: Binding<ToolSelection>?

  /// Used only if a user passes in a canvas size value.
  /// Otherwise size is measured internally.
  let explicitCanvasSize: Size<CanvasSpace>?
  let content: () -> Content

  /// Creates an interactive canvas around SwiftUI content.
  ///
  /// - Parameters:
  ///   - size: Optional fixed canvas size. Pass `nil` to measure the content.
  ///   - transform: Optional external source of truth for pan, zoom, and rotation.
  ///   - coordinateSpaceMapper: Optional binding that receives the current mapper.
  ///   - pointerStyle: Optional binding that receives the style resolved by the current tool.
  ///   - toolConfiguration: Optional initial tool catalogue and shortcut policy.
  ///   - toolSelection: Optional parent-owned committed tool selection. The
  ///     selection is normalised against `toolConfiguration`, synchronised in
  ///     both directions, and never receives transient key-held overrides.
  ///   - content: The artwork or document view rendered inside the canvas.
  public init(
    size: CGSize? = nil,
    transform: Binding<TransformState>? = nil,
    coordinateSpaceMapper: Binding<CoordinateSpaceMapper?>? = nil,
    pointerStyle: Binding<CanvasPointerStyle?>? = nil,
    toolConfiguration: ToolConfiguration? = nil,
    toolSelection: Binding<ToolSelection>? = nil,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.explicitCanvasSize = size.map { Size<CanvasSpace>(fromCGSize: $0) }
    self.externalTransform = transform
    self.externalCoordinateSpaceMapper = coordinateSpaceMapper
    self.externalPointerStyle = pointerStyle
    self.externalToolSelection = toolSelection
    self._store = State(
      initialValue: .init(
        toolConfiguration: toolConfiguration,
        toolSelection: toolSelection?.wrappedValue,
        currentTransform: transform?.wrappedValue ?? .identity,
      )
    )
    self.content = content
  }

  public var body: some View {
    @Bindable var store = store

    CanvasCoreView(content: content)

      // User input modifiers, `onSwipeGesture`, `onTapGesture`, etc.
      // These wrap the canvas only, so their invisible event-capture overlays
      // don't sit above the tool picker.
      .modifier(InteractionModifiers())
      .canvasPointerStyle(store.pointerStyle)
      .modifier(ToolsPaletteViewModifier())

      // Adds canvas transform and mapped pointer values to the Environment (for internal use only)
      .updateTransformEnvironment()
      .updatePointerEnvironment()

      // The external binding owns the transform when supplied. On appearance,
      // hydrate this CanvasView's newly created handler from that value; then
      // keep local interaction updates and external programmatic updates in sync.
      .bindModel(
        debounce: .noDebounce,
        $store.currentTransform,
        to: externalTransform,
        initially: .viewToModel,
      )

      // The parent owns committed selection when a binding is supplied. The
      // handler was seeded from that binding in init; model-to-view initial
      // synchronisation writes any catalogue normalisation back to the parent.
      .bindModel(
        debounce: .noDebounce,
        $store.committedToolSelection,
        to: externalToolSelection,
        initially: .modelToView,
      ) { _ in
        // A parent can later supply an id that is absent from the catalogue.
        // The computed model setter repairs it; reflect that repaired value
        // even when the normalised model value itself did not change.
        let normalisedSelection = store.committedToolSelection
        guard externalToolSelection?.wrappedValue != normalisedSelection else { return }
        externalToolSelection?.wrappedValue = normalisedSelection
      }

      .syncValue(
        store.coordinateSpaceMapper(in: explicitCanvasSize),
        to: externalCoordinateSpaceMapper,
      )

      .syncValue(store.pointerStyle, to: externalPointerStyle)

      // Listens for keys pressed based on ToolHandler's `keysToWatch`
      .onCanvasToolKeyboardPress()

      // Listens for Modifier key presses and adds to Environment
      .modifierKeys { modifiers in
        store.updateModifiers(.init(from: modifiers))
      }

      .environment(\.explicitCanvasSize, explicitCanvasSize)
      .environment(store)

      .onDisappear {
        externalCoordinateSpaceMapper?.wrappedValue = nil
        externalPointerStyle?.wrappedValue = nil
      }

  }
}
