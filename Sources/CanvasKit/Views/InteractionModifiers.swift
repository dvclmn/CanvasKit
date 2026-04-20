//
//  InteractionModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/3/2026.
//

import BasePrimitives
import SwiftUI

struct InteractionModifiers: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.modifierKeys) private var modifierKeys

  @Bindable var state: CanvasState
//  @Binding var transform: TransformState
  let tool: (any CanvasTool)?

  func body(content: Content) -> some View {
    @Bindable var store = store

    content
      .onSwipeGesture(
        isEnabled: isEnabled(for: .swipe)
      ) { event in

        let adjustment = store.processedTransform(
          .swipe(delta: event.delta),
          tool: tool,
          phase: event.phase,
          modifiers: event.modifiers,
          currentTransform: state.transform,
        )
        guard let adjustment else { return }
        state.transform = adjustment
      }

      .onPinchGesture(
        initial: state.transform.scale,
        isEnabled: isEnabled(for: .pinch),
      ) { zoom, phase in

        let adjustment = store.processedTransform(
          .pinch(scale: zoom),
          tool: tool,
          phase: phase,
          modifiers: modifierKeys,
          currentTransform: state.transform,
        )

        /// Returns the scale so the modifier's internal Zoom
        /// stays in sync with transform state
        guard let adjustment else {
          return adjustment?.scale
        }
        state.transform = adjustment
        return adjustment.scale

      }

      .onContinuousHover(coordinateSpace: .named(ScreenSpace.screen)) { phase in
        guard isEnabled(for: .hover), let location = phase.location else { return }
        let adjustment = store.processedTransform(
          .hover(location.screenPoint),
          tool: tool,
          phase: phase.interactionPhase,
          modifiers: modifierKeys,
          currentTransform: state.transform,
        )
        guard let adjustment else { return }
        state.transform = adjustment

      }

      .onTapGesture(coordinateSpace: .named(ScreenSpace.screen)) { location in
        guard isEnabled(for: .tap) else { return }
        let adjustment = store.processedTransform(
          .tap(location: location.screenPoint),
          tool: tool,
          phase: .ended,
          modifiers: modifierKeys,
          currentTransform: state.transform,
        )
        guard let adjustment else { return }
        state.transform = adjustment

      }

      .onPointerDragGesture(
        behaviour: tool?.dragBehaviour ?? .none,
        isEnabled: isEnabled(for: .drag),
      ) { payload, phase in
        guard let payload else { return }
        let adjustment = store.processedTransform(
          .drag(payload),
          tool: tool,
          phase: phase,
          modifiers: modifierKeys,
          currentTransform: state.transform,
        )
        guard let adjustment else { return }
        state.transform = adjustment
      }
  }
}

extension InteractionModifiers {
  private func isEnabled(for interaction: InteractionKind) -> Bool {
    let enabled: Bool

    switch interaction {
      case .swipe, .pinch, .rotate:
        enabled = true

      case .tap, .drag, .hover:
        guard let tool else {
          enabled = false
          break
        }

        enabled = tool.inputCapabilities.contains { capability in
          capability.interactionKind == interaction
        }
    }

//    if !enabled {
//      let capabilities = tool?.inputCapabilities.map(\.description).joined(separator: ", ") ?? "no tool"
//      print("Interaction \(interaction.displayName) is not enabled for \(capabilities)")
//    }
    return enabled
//    guard let tool else { return true }
//    return tool.inputCapabilities.contains(interaction)
  }
}
