//
//  InteractionModifiers.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/3/2026.
//

import CoreTools
import SwiftUI

struct InteractionModifiers: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.modifierKeysNative) private var modifierKeysNative
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
          modifiers: modifierKeysNative,
        )
        apply(adjustment)
      }

      .onPinchGesture(
        initial: store.currentTransform.scale,
        zoom: $store.currentTransform.scale,
        isEnabled: isEnabled(for: .pinch),
      ) { zoom, phase in

        let adjustment = store.processedTransform(
          .pinch(scale: zoom),
          phase: phase,
          modifiers: modifierKeysNative,
        )

        // Return the scale so the modifier's internal zoom
        // stays in sync with transform state.
        apply(adjustment)
//        return store.currentTransform.scale
        return adjustment?.scale
      }

      .onContinuousHover(coordinateSpace: .named(ViewportSpace.viewport)) { phase in
        guard isEnabled(for: .hover), let location = phase.location else { return }
        let adjustment = store.processedTransform(
          .hover(location.viewportPoint),
          phase: phase.interactionPhase,
          modifiers: modifierKeysNative,
        )
        apply(adjustment)

      }

      .onTapGesture(coordinateSpace: .named(ViewportSpace.viewport)) { location in
        //        printTimestamped("Called `onTapGesture`")
        guard isEnabled(for: .tap) else { return }
        let adjustment = store.processedTransform(
          .tap(location: location.viewportPoint),
          phase: .ended,
          modifiers: modifierKeysNative,
        )
        apply(adjustment)

      }

      .onPointerDragGesture(
        behaviour: store.effectiveTool.dragConfiguration.behaviour,
        isEnabled: isEnabled(for: .drag),
        minimumDistance: store.effectiveTool.dragConfiguration.minimumDistance,
      ) { payload, phase in

        //        printTimestamped("Called `onPointerDragGesture`")
        guard let payload else { return }
        let adjustment = store.processedTransform(
          .drag(payload),
          phase: phase,
          modifiers: modifierKeysNative,
        )
        apply(adjustment)
      }
  }
}

extension InteractionModifiers {
  private func apply(_ adjustment: TransformState?) {
    guard var adjustment else { return }
    adjustment.scale = adjustment.scale.clamped(to: zoomRange)
    store.currentTransform = adjustment
  }

  private func isEnabled(
    for interaction: InteractionKind
  ) -> Bool {
    let isEnabled: Bool

    switch interaction {
      case .swipe, .pinch, .rotate:
        isEnabled = true

      case .tap, .drag, .hover:
        // Returns true if any of the current tool's capabilities match this interaction.
        isEnabled = store.effectiveTool.inputCapabilities.contains { capability in
          capability.interactionKind == interaction
        }
    }
    return isEnabled
  }
}
