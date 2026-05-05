//
//  InteractionModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/3/2026.
//

import CoreUtilities
import GeometryPrimitives
import SwiftUI

struct InteractionModifiers: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.modifierKeys) private var modifierKeys
  @Environment(\.zoomRange) private var zoomRange

  func body(content: Content) -> some View {
    @Bindable var store = store

    content
      .onSwipeGesture(
        isEnabled: isEnabled(for: .swipe)
      ) { event in

        let adjustment = store.processedTransform(
          .swipe(delta: event.delta),
          phase: event.phase,
          modifiers: event.modifiers,
//          currentTransform: transform,
        )
        apply(adjustment)
      }

      .onPinchGesture(
        initial: store.currentTransform.scale,
        isEnabled: isEnabled(for: .pinch),
      ) { zoom, phase in

        let adjustment = store.processedTransform(
          .pinch(scale: zoom),
          phase: phase,
          modifiers: modifierKeys,
//          currentTransform: transform,
        )

        /// Returns the scale so the modifier's internal Zoom
        /// stays in sync with transform state
        return apply(adjustment)?.scale
      }

      .onContinuousHover(coordinateSpace: .named(ViewportSpace.viewport)) { phase in
        guard isEnabled(for: .hover), let location = phase.location else { return }
        let adjustment = store.processedTransform(
          .hover(location.viewportPoint),
          phase: phase.interactionPhase,
          modifiers: modifierKeys,
//          currentTransform: transform,
        )
        apply(adjustment)

      }

      .onTapGesture(coordinateSpace: .named(ViewportSpace.viewport)) { location in
        guard isEnabled(for: .tap) else { return }
        let adjustment = store.processedTransform(
          .tap(location: location.viewportPoint),
          phase: .ended,
          modifiers: modifierKeys,
//          currentTransform: transform,
        )
        apply(adjustment)

      }

      .onPointerDragGesture(
        behaviour: store.effectiveTool.dragBehaviour,
        isEnabled: isEnabled(for: .drag),
      ) { payload, phase in
        guard let payload else { return }
        let adjustment = store.processedTransform(
          .drag(payload),
          phase: phase,
          modifiers: modifierKeys,
//          currentTransform: transform,
        )
        apply(adjustment)
      }
  }
}

extension InteractionModifiers {
  @discardableResult
  private func apply(_ adjustment: TransformState?) -> TransformState? {
    guard var adjustment else { return nil }
    adjustment.scale = adjustment.scale.clamped(to: zoomRange)
    store.currentTransform = adjustment
    return adjustment
  }

  private func isEnabled(for interaction: InteractionKind) -> Bool {
    let isEnabled: Bool

    switch interaction {
      case .swipe, .pinch, .rotate:
        isEnabled = true

      case .tap, .drag, .hover:
        isEnabled = store.effectiveTool.inputCapabilities.contains { capability in
          capability.interactionKind == interaction
        }
    }

    return isEnabled
  }
}
