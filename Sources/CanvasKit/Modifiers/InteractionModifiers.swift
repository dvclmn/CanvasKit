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
      .onSwipeGesture(isEnabled: policy.panGestureEnabled) { event in
        interactionState.handleInput(
          from: .swipeGesture(
            delta: event.delta,
            location: event.location
          ),
          phase: event.phase,
          modifiers: event.modifiers
        )
      }

      .onPinchGesture(
        initial: interactionState.transform.scale,
        isEnabled: policy.pinchGestureEnabled,
        didUpdateEvent: { event, phase in
          interactionState.handleInput(
            from: .pinchGesture(event),
            phase: phase,
            modifiers: modifierKeys
          )
          /// Return the resolved scale so the modifier's internalZoom
          /// stays in sync with what GlobalInteraction wrote to transform.scale.
          return interactionState.transform.scale
        }
      )

      .onContinuousHover(coordinateSpace: .named(ScreenSpace.screen)) { phase in
        guard let location = phase.location else { return }
        interactionState.handleInput(
          from: .continuousHover(location.screenPoint), phase: phase.interactionPhase, modifiers: modifierKeys
        )
      }

      .onTapGesture(
        count: 1,
        coordinateSpace: .named(ScreenSpace.screen)
      ) { location in
        interactionState.handleInput(
          from: .pointerTapGesture(
            .primary,
            location: location.screenPoint
          ),
          phase: .ended,
          modifiers: modifierKeys
        )
      }

      .onPointerDragGesture(
        behaviour: policy.dragBehaviour
      ) { payload, phase in
        guard let payload else { return }
        interactionState.handleInput(
          from: .pointerDragGesture(payload),
          phase: phase,
          modifiers: modifierKeys
        )
      }
  }
}
extension InteractionModifiers {

  private var zoom: Double {
    interactionState.transform.scale.toDouble
  }
}

extension View {
  public func canvasTransformations() -> some View {
    self.modifier(InteractionModifiers())
  }
}
