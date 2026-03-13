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
  @Environment(\.canvasInteractionPolicy) private var policy
  @Environment(\.canvasGeometry) private var canvasGeometry
  @Environment(\.zoomRange) private var zoomRange

  func body(content: Content) -> some View {
    @Bindable var store = store
    @Bindable var interactionState = interactionState

    content
      .panGesture(isEnabled: policy.panGestureEnabled) { delta, phase, _ in
        interactionState.transform.pan.updateDelta(delta, phase: phase)
      }

      .zoomGesture(
        zoom: $interactionState.transform.zoom.value.toBindingDouble,
        isEnabled: policy.zoomGestureEnabled,
        didUpdateEvent: { store.handleZoom($0, geometry: canvasGeometry, state: &interactionState) }
      )

      .onContinuousHover(coordinateSpace: .named(CanvasSpace.viewport)) { phase in
        guard policy.hoverEnabled else { return }
        handleHover(phase)
      }

      .tapDragGesture(
        rect: dragRectBinding(),
        behaviour: policy.dragBehaviour,
        drawsMarqueeRect: true,  // Need to hook this up properly
        minimumDistance: interactionState.pointer.dragThreshold,
        didUpdateTap: { store.handleTap(at: $0, zoom: zoom, state: &interactionState) }
      )

  }
}
extension TransformationsModifier {
  private func dragRectBinding() -> Binding<CGRect?> {
    switch policy.dragBehaviour {
      case .marquee:
        return Binding {
          interactionState.pointer.drag.value
        } set: {
          interactionState.pointer.drag.value = $0
        }
      case .continuous:
        return Binding {
          interactionState.pan.toCGRectZeroOrigin
        } set: {
          guard let size = $0?.size else { return }
          interactionState.transform.pan.update(size, phase: .changed)
        }
      case .none:
        return .constant(nil)
    }
  }

  private var zoom: CGFloat {
    interactionState.zoom.toCGFloat
  }
}

extension View {
  public func canvasTransformations() -> some View {
    self.modifier(TransformationsModifier())
  }
}
