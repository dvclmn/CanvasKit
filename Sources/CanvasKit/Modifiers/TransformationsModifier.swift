//
//  TransformationsModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/3/2026.
//

import BasePrimitives
//import GestureKit
import SwiftUI

struct TransformationsModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.canvasInputPolicy) private var policy
  @Environment(\.canvasGeometry) private var canvasGeometry
  @Environment(\.modifierKeys) private var modifierKeys

  func body(content: Content) -> some View {
    @Bindable var store = store
//    @Bindable var interactionState = interactionState

    content
      .swipeGesture(isEnabled: policy.panGestureEnabled) { event in
        
//        interactionState.handleSwipeGesture(event, with: <#T##Interaction#>)
        //        interactionState.handleSwipeGesture(event)
      }

      .zoomGesture(
        initial: interactionState.transform.scale,
        isEnabled: policy.zoomGestureEnabled,
        didUpdateEvent: { event in
          interactionState.handleInput(from: .pinchGesture(event), phase: <#T##InteractionPhase#>, modifiers: <#T##Modifiers#>)
//          store.handleZoom(
//            event,
//            geometry: canvasGeometry,
//            state: &interactionState
//          )
        }
      )

      .onContinuousHover(coordinateSpace: .named(ScreenSpace.screen)) { phase in
        interactionState.handleHover(phase)
      }

      .onTapGesture(
        count: 1,
        coordinateSpace: .named(ScreenSpace.screen)
      ) {
        store.handleTap(at: $0, zoom: zoom, state: &interactionState)
      }

      .pointerDragGesture(
        rect: $interactionState.dragRect,
        //        rect: interactionState.dragRectBinding(using: policy),
        coordinateSpace: .named(ScreenSpace.screen),
        behaviour: policy.dragBehaviour,
        drawsMarqueeRect: true,
        minimumDistance: interactionState.pointer.dragThreshold
      )

  }
}
extension TransformationsModifier {

  private var zoom: Double {
    state.transform.scale.value.toDouble
  }
}

extension View {
  public func canvasTransformations() -> some View {
    self.modifier(TransformationsModifier())
  }
}
