//
//  TransformationsModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/3/2026.
//

import BasePrimitives
import GestureKit
import SwiftUI

struct TransformationsModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(CanvasInteractionState.self) private var state
  @Environment(\.canvasInputPolicy) private var policy
  @Environment(\.canvasGeometry) private var canvasGeometry
  @Environment(\.modifierKeys) private var modifierKeys

  func body(content: Content) -> some View {
    @Bindable var store = store
    @Bindable var state = state

    content
      .panGesture(isEnabled: policy.panGestureEnabled) { event in
        state.handleSwipeGesture(event)
      }

      .zoomGesture(
        zoom: $state.transform.scale.value,
        isEnabled: policy.zoomGestureEnabled,
        didUpdateEvent: {
          store.handleZoom(
            $0,
            geometry: canvasGeometry,
            state: &state
          )
        }
      )

      .onContinuousHover(coordinateSpace: .named(ScreenSpace.screen)) { phase in

      }

      .onTapGesture(
        count: 1,
        coordinateSpace: .named(ScreenSpace.screen)
      ) {
        store.handleTap(at: $0, zoom: zoom, state: &state)
      }

      .pointerDragGesture(
        rect: $state.dragRect,
        //        rect: interactionState.dragRectBinding(using: policy),
        coordinateSpace: .named(ScreenSpace.screen),
        behaviour: policy.dragBehaviour,
        drawsMarqueeRect: true,
        minimumDistance: state.pointer.dragThreshold
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
