//
//  InteractionModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/3/2026.
//

import InteractionKit
import SwiftUI

struct InteractionModifiers: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.activeTool) private var activeTool
  @Environment(\.modifierKeys) private var modifierKeys

  func body(content: Content) -> some View {
    @Bindable var store = store

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
        store.handleInteraction(
          .swipeGesture(
            delta: event.delta,
            location: event.location,
          ),
          phase: event.phase,
        )
      }

      .onPinchGesture(
        initial: store.transform.scale,
        isEnabled: true,
        //        isEnabled: policy.activeInputs.contains(.pinch)
      ) { zoom, phase in
        store.handleInteraction(
          .pinchGesture(scale: zoom),
          phase: phase,
          //          modifiers: modifierKeys
        )
        /// Return the resolved scale so the modifier's internalZoom
        /// stays in sync with what GlobalInteraction wrote to transform.scale.
        return store.transform.scale
      }

      .onContinuousHover(coordinateSpace: .named(ScreenSpace.screen)) { phase in
        //        guard policy.activeInputs.contains(.pointerHover) else { return }
        guard let location = phase.location else { return }
        store.handleInteraction(
          .continuousHover(location.screenPoint),
          phase: phase.interactionPhase,
        )
      }

      .onTapGesture(
        count: 1,
        coordinateSpace: .named(ScreenSpace.screen),
      ) { location in
        //        guard policy.activeInputs.contains(.pointerTap) else { return }
        store.handleInteraction(
          .pointerTapGesture(.primary, location: location.screenPoint),
          phase: .ended,
        )
      }

      .onPointerDragGesture(
        behaviour: activeTool?.dragBehaviour ?? .none
          //        behaviour: policy.dragBehaviour
      ) { payload, phase in
        guard let payload else { return }
        store.handleInteraction(.pointerDragGesture(payload), phase: phase)
      }

      /// Make sure `CanvasHandler` gets modifier key updates
      .task(id: modifierKeys) { store.updateModifiers(to: modifierKeys) }
      .task(id: activeTool?.kind) { store.updateTool(to: activeTool) }

      
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
