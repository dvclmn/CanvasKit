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
  @Environment(CanvasInteraction.self) private var interactionState
  @Environment(\.canvasInteractionPolicy) private var policy
  @Environment(\.canvasGeometry) private var canvasGeometry
  @Environment(\.zoomRange) private var zoomRange

  func body(content: Content) -> some View {
    @Bindable var store = store
    @Bindable var interactionState = interactionState

    content
      .panGesture(isEnabled: policy.panGestureEnabled) { delta, phase, _ in
        interactionState.transform.panState.updateDelta(delta, phase: phase)
      }

      .zoomGesture(
        zoom: $interactionState.transform.zoomState.value.toBindingDouble,
        isEnabled: policy.zoomGestureEnabled,
        didUpdateEvent: {
          guard let canvasGeometry else {
            let newZoom = $0.magnification
            interactionState.transform.zoomState.update(newZoom, phase: $0.phase)
            return newZoom
          }
          return store.updateZoom(
            using: $0,
            interactionState: &interactionState,
            geometry: canvasGeometry,
            in: zoomRange
          )
        }
      )

      .tapDragGesture(
        rect: dragRectBinding(),
        behavior: policy.dragBehaviour,
        minimumDistance: interactionState.pointer.dragState.dragThreshold,
        didUpdateTap: { location in
          handleTap(at: location)
        }
      )

      .onContinuousHover(coordinateSpace: .named(CanvasSpace.viewport)) { phase in
        guard policy.hoverEnabled else { return }
        handleHover(phase)
      }

  }
}
extension TransformationsModifier {
  private func dragRectBinding() -> Binding<CGRect?> {
    switch policy.dragBehaviour {
      case .marquee:
        return Binding {
          interactionState.pointer.dragState.value
        } set: {
          interactionState.pointer.dragState.value = $0
        }
      case .continuous:
        return Binding {
          interactionState.transform.panState.pan.toCGRectZeroOrigin
        } set: {
          guard let size = $0?.size else { return }
          interactionState.transform.panState.update(size, phase: .changed)
        }
      case .none:
        return .constant(nil)
    }
  }

  private func handleTap(at location: CGPoint) {
    let mapped = store.mappedTapLocation(location, zoom: zoom)
    interactionState.pointer.tapState.update(mapped)
  }

  private func handleHover(_ phase: HoverPhase) {
    let mapped = store.mappedHoverLocation(phase, zoom: zoom)
    interactionState.pointer.hoverState.update(mapped)
  }

  private var zoom: CGFloat {
    interactionState.transform.zoomState.zoom.toCGFloat
  }
}

extension View {
  public func canvasTransformations() -> some View {
    self.modifier(TransformationsModifier())
  }
}
