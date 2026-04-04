//
//  InteractionModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/3/2026.
//

import InteractionKit
import SwiftUI

struct InteractionModifiers: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.activeTool) private var activeTool
  @Environment(\.modifierKeys) private var modifierKeys

  func body(content: Content) -> some View {
    @Bindable var interactionState = interactionState

    // TODO: Need to determine whether a CanvasTool might:
    // a) Need to be given scoped-down interaction capabilities
    // (aka *can't* use swipe, or pinch)
    //
    // or b) Might want to enable/disable these inputs itself
    content
      .onSwipeGesture(
        isEnabled: true
          //        isEnabled: policy.activeInputs.contains(.swipe)
      ) { event in
        interactionState.handleInput(
          .swipeGesture(
            delta: event.delta,
            location: event.location,
          ),
          phase: event.phase,
        )
      }

      .onPinchGesture(
        initial: interactionState.transform.scale,
        isEnabled: true,
        //        isEnabled: policy.activeInputs.contains(.pinch)
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
        //        guard policy.activeInputs.contains(.pointerHover) else { return }
        guard let location = phase.location else { return }
        interactionState.handleInput(
          .continuousHover(location.screenPoint),
          phase: phase.interactionPhase,
        )
      }

      .onTapGesture(
        count: 1,
        coordinateSpace: .named(ScreenSpace.screen),
      ) { location in
        //        guard policy.activeInputs.contains(.pointerTap) else { return }
        interactionState.handleInput(
          .pointerTapGesture(.primary, location: location.screenPoint),
          phase: .ended,
        )
      }

      .onPointerDragGesture(
        behaviour: activeTool?.dragBehaviour ?? .none
          //        behaviour: policy.dragBehaviour
      ) { payload, phase in
        guard let payload else { return }
        interactionState.handleInput(.pointerDragGesture(payload), phase: phase)
      }

      /// Make sure `CanvasInteractionState` gets modifier key updates
      .task(id: modifierKeys) { interactionState.updateModifiers(to: modifierKeys) }
      .task(id: activeTool?.kind) { interactionState.updateTool(to: activeTool) }

    //      .syncEnvironment(\.modifierKeys) { interactionState.updateModifiers(to: $0) }
    //      .syncEnvironment(\.activeTool, using: \.?.kind) { interactionState.updateTool(to: $0) }
    //      .syncModifiers(to: $interactionState.modifiers)
  }
}

extension View {
  public func gestureModifiers() -> some View {
    self.modifier(InteractionModifiers())
  }
}
