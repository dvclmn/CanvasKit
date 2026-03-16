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
  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.canvasInputPolicy) private var policy
  @Environment(\.canvasGeometry) private var canvasGeometry

  func body(content: Content) -> some View {
    @Bindable var store = store
    @Bindable var interactionState = interactionState

    content
      .panGesture(isEnabled: policy.panGestureEnabled) { delta, phase, _ in
        store.handlePan(delta: delta, phase: phase, state: &interactionState)
      }

      .zoomGesture(
        zoom: $interactionState.transform.zoom.value,
        isEnabled: policy.zoomGestureEnabled,
        didUpdateEvent: {
          store.handleZoom(
            $0,
            geometry: canvasGeometry,
            state: &interactionState
          )
        }
      )

      .onContinuousHover(coordinateSpace: .named(CanvasSpace.viewport)) { phase in
        guard policy.hoverEnabled else { return }
        store.handleHover(phase, zoom: zoom, state: &interactionState)
      }

      .onTapGesture(count: 1, coordinateSpace: .named(CanvasSpace.viewport)) {
        store.handleTap(at: $0, zoom: zoom, state: &interactionState)
      }

      .tapDragGesture(
        rect: interactionState.dragRectBinding(using: policy),
        coordinateSpace: .named(CanvasSpace.viewport),
        behaviour: policy.dragBehaviour,
        drawsMarqueeRect: true,
        minimumDistance: interactionState.pointer.dragThreshold
      )

  }
}
extension TransformationsModifier {

  private var zoom: Double {
    interactionState.zoom.toDouble
  }
}

extension View {
  public func canvasTransformations() -> some View {
    self.modifier(TransformationsModifier())
  }
}
