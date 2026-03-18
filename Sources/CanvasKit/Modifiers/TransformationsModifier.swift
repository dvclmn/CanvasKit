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

//  @State private var dragRect: CGRect?

  func body(content: Content) -> some View {
    @Bindable var store = store
    @Bindable var interactionState = interactionState

    content
      .swipeGesture(isEnabled: policy.panGestureEnabled) { event in
        interactionState.handleInput(
          from: .swipeGesture(delta: event.delta, location: event.location), phase: event.phase,
          modifiers: event.modifiers)
      }

      .pinchGesture(
        initial: interactionState.transform.scale,
        isEnabled: policy.pinchGestureEnabled,
        didUpdateEvent: { event, phase in
          interactionState.handleInput(from: .pinchGesture(event), phase: phase, modifiers: modifierKeys)

          /// Not sure if I should actually return a zoom value here
          return nil
        }
      )

      .onContinuousHover(coordinateSpace: .named(ScreenSpace.screen)) { phase in
        guard let location = phase.location else { return }
        interactionState.handleInput(
          from: .continuousHover(location.screenPoint), phase: phase.interactionPhase, modifiers: modifierKeys
        )
        //        interactionState.handleHover(phase)
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
        //        store.handleTap(at: $0, zoom: zoom, state: &interactionState)
      }

      .pointerDragGesture(
        observing: $interactionState.pointer.drag,  // read-only sync
        behaviour: policy.dragBehaviour
      ) { event, phase in
        interactionState.handleInput(
          from: .pointerDragGesture(
            from: event.startLocation,
            current: event.currentLocation
          ),
          phase: phase,
          modifiers: modifierKeys
        )
      }
    
//      .pointerDragGesture(
//        rect: $dragRect,
//        //        rect: $interactionState.pointer.drag,
//        //        rect: $interactionState.dragRect,
//        //        rect: interactionState.dragRectBinding(using: policy),
//        coordinateSpace: .named(ScreenSpace.screen),
//        behaviour: policy.dragBehaviour,
//        drawsMarqueeRect: true,
//        minimumDistance: interactionState.pointer.dragThreshold
//      )
//    
//      .onChange(of: dragRect) {
//        guard let dragRect else { return }
//
//        //        guard let origin = dragRect?.origin, let current = dragRect?.size
//        interactionState.handleInput(
//          from: .pointerDragGesture(
//            from: .init(fromPoint: dragRect.origin),
//            current: .init(fromOffset: dragRect.size)
//          ),
//          phase: <#T##InteractionPhase#>,
//          modifiers: <#T##Modifiers#>
//        )
//      }

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
