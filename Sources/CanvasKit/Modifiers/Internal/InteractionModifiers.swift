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
          .swipe(
            delta: event.delta,
//            location: event.location,
          ),
          phase: event.phase,
        )
      }

      .onPinchGesture(
        initial: store.transform.scale,
        isEnabled: true,
        //        isEnabled: policy.activeInputs.contains(.pinch)
      ) { zoom, phase in
        store.handleInteraction(.pinch(scale: zoom),phase: phase)
        /// Return the resolved scale so the modifier's internalZoom
        /// stays in sync with what GlobalInteraction wrote to transform.scale.
        return store.transform.scale
      }

      .onContinuousHover(coordinateSpace: .named(ScreenSpace.screen)) { phase in
        //        guard policy.activeInputs.contains(.pointerHover) else { return }
        guard let location = phase.location else { return }
        store.handleInteraction(
          .hover(location.screenPoint),
          phase: phase.interactionPhase,
        )
      }

      .onTapGesture(
        count: 1,
        coordinateSpace: .named(ScreenSpace.screen),
      ) { location in
        //        guard policy.activeInputs.contains(.pointerTap) else { return }
        store.handleInteraction(
          .tap(location: location.screenPoint),
          phase: .ended,
        )
      }

      .onPointerDragGesture(behaviour: activeTool?.dragBehaviour ?? .none) { payload, phase in
        guard let payload else { return }
        store.handleInteraction(.drag(payload), phase: phase)
      }
  }
}

extension View {
  public func gestureModifiers() -> some View {
    self.modifier(InteractionModifiers())
  }
}
