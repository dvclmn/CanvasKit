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
  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.canvasInputPolicy) private var policy
  @Environment(\.canvasGeometry) private var canvasGeometry
  @Environment(\.modifierKeys) private var modifierKeys

  func body(content: Content) -> some View {
    @Bindable var store = store
    @Bindable var interactionState = interactionState

    content
      .onSwipeGesture(
        isEnabled: policy.activeInputs.contains(.swipeGesture)
      ) { event in
        interactionState.handleInput(
          .swipeGesture(
            delta: event.delta,
            location: event.location
          ),
          phase: event.phase,
          //          modifiers: event.modifiers
        )
      }

      .onPinchGesture(
        initial: interactionState.transform.scale,
        isEnabled: policy.activeInputs.contains(.pinchGesture)
      ) { zoom, phase in
        interactionState.handleInput(
          .pinchGesture(scale: zoom),
          phase: phase,
          //          modifiers: modifierKeys
        )
        /// Return the resolved scale so the modifier's internalZoom
        /// stays in sync with what GlobalInteraction wrote to transform.scale.
        return interactionState.transform.scale
      }

      .onContinuousHover(coordinateSpace: .named(ScreenSpace.screen)) { phase in
        guard policy.activeInputs.contains(.pointerHover) else { return }
        guard let location = phase.location else { return }
        interactionState.handleInput(
          .continuousHover(location.screenPoint),
          phase: phase.interactionPhase,
          //          modifiers: modifierKeys
        )
      }

      .onTapGesture(
        count: 1,
        coordinateSpace: .named(ScreenSpace.screen)
      ) { location in
        guard policy.activeInputs.contains(.pointerTapGesture) else { return }
        interactionState.handleInput(
          .pointerTapGesture(
            .primary,
            location: location.screenPoint
          ),
          phase: .ended,
          //          modifiers: modifierKeys
        )
      }

      .onPointerDragGesture(
        behaviour: policy.dragBehaviour
      ) { payload, phase in
        guard let payload else { return }
        interactionState.handleInput(
          .pointerDragGesture(payload),
          phase: phase,
          //          modifiers: modifierKeys
        )
      }

    /// Make sure `CanvasInteractionState` gets modifier key updates
      .task(id: modifierKeys) { interactionState.modifiers = modifierKeys }
  }
}

extension View {
  public func canvasTransformations() -> some View {
    self.modifier(InteractionModifiers())
  }
}
