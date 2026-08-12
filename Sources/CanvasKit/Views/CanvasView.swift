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
  ///   - toolConfiguration: Optional custom tool catalogue and shortcut policy.
  ///   - content: The artwork or document view rendered inside the canvas.
  public init(
    size: CGSize? = nil,
    transform: Binding<TransformState>? = nil,
    coordinateSpaceMapper: Binding<CoordinateSpaceMapper?>? = nil,
    pointerStyle: Binding<CanvasPointerStyle?>? = nil,
    toolConfiguration: ToolConfiguration? = nil,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.explicitCanvasSize = size.map { Size<CanvasSpace>(fromCGSize: $0) }
    self.externalTransform = transform
    self.externalCoordinateSpaceMapper = coordinateSpaceMapper
    self.externalPointerStyle = pointerStyle
    self._store = State(
      initialValue: .init(
        toolConfiguration: toolConfiguration,
        currentTransform: transform?.wrappedValue ?? .identity,
      )
    )
    self.content = content
  }

  public var body: some View {
    CanvasCoreView(content: content)

      // User input modifiers, `onSwipeGesture`, `onTapGesture`, etc.
      // These wrap the canvas only, so their invisible event-capture overlays
      // do not sit above the tool picker.
      .modifier(InteractionModifiers())
      .canvasPointerStyle(store.pointerStyle)
      .modifier(ToolsPaletteViewModifier())

      // Adds canvas transform and mapped pointer values to the Environment.
      .updateTransformEnvironment()
      .updatePointerEnvironment()

      // TODO: ToolKit's `bindModel(debounce:_:to:initially:perform:)`
      // should be able to handle the below now, as it's been updated
      //
      // When transform state is externally owned, hydrate the local handler
      // before synchronising subsequent changes in both directions.
      .onAppear {
        synchroniseTransformFromExternal(externalTransform?.wrappedValue)
      }
      .onChange(of: store.currentTransform) { _, transform in
        synchroniseExternalTransform(from: transform)
      }
      .onChange(of: externalTransform?.wrappedValue) { _, transform in
        synchroniseTransformFromExternal(transform)
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

      .environment(\.canvasCoordinateSpaceMapper, store.coordinateSpaceMapper(in: explicitCanvasSize))
      .environment(\.explicitCanvasSize, explicitCanvasSize)
      .environment(\.latestInteraction, store.latestInteraction)
      .environment(\.activeInteraction, store.activeInteraction)
      .environment(store)

      .onDisappear {
        externalCoordinateSpaceMapper?.wrappedValue = nil
        externalPointerStyle?.wrappedValue = nil
      }

  }
}

extension CanvasView {
  fileprivate func synchroniseTransformFromExternal(_ transform: TransformState?) {
    guard let transform else { return }
    guard store.currentTransform != transform else { return }
    store.currentTransform = transform
  }

  fileprivate func synchroniseExternalTransform(from transform: TransformState) {
    guard let externalTransform else { return }
    guard externalTransform.wrappedValue != transform else { return }
    externalTransform.wrappedValue = transform
  }
}

// MARK: - Inits
extension CanvasView {

}
