//
//  InteractionModifiers.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/3/2026.
//

private import CoreTools
import SwiftUI
private import ViewTools

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
        store.processInteraction(
          .swipe(delta: event.delta),
          phase: event.phase,
          modifiers: event.modifiers,
          zoomRange: zoomRange,
        )
      }

      .onPinchGesture(
        zoom: $store.currentTransform.scale,
        isEnabled: isEnabled(for: .pinch),
      ) { proposal in

        //        let adjustment = store.processInteraction(
        //          .pinch(scale: proposal.proposedZoom),
        //          phase: proposal.phase,
        //          modifiers: modifiers,
        //          zoomRange: zoomRange
        //        )

        let transform = store.processInteraction(
          .pinch(scale: proposal.proposedZoom),
          phase: proposal.phase,
          modifiers: modifiers,
          zoomRange: zoomRange,
        )

        // Resolve to the processed transform so the modifier's working zoom
        // stays aligned with any tool-specific transform policy.
        return transform?.scale ?? proposal.proposedZoom
      }

      .onContinuousHover(coordinateSpace: .named(ViewportSpace.viewport)) { phase in
        guard let location = phase.location else {
          store.endInteraction(
            .hover,
            phase: phase.interactionPhase,
            modifiers: modifiers,
          )
          return
        }
        store.processInteraction(
          .hover(location.viewportPoint),
          phase: phase.interactionPhase,
          modifiers: modifiers,
          zoomRange: zoomRange,
        )
        //        apply(adjustment)
      }

      .onTapGesture(coordinateSpace: .named(ViewportSpace.viewport)) { location in
        guard isEnabled(for: .tap) else { return }
        store.processInteraction(
          .tap(location: location.viewportPoint),
          phase: .ended,
          modifiers: modifiers,
          zoomRange: zoomRange,
        )
        //        apply(adjustment)
      }

      .onPointerDragGesture(
        behaviour: store.effectiveTool.dragConfiguration.behaviour,
        isEnabled: isEnabled(for: .drag),
        minimumDistance: store.effectiveTool.dragConfiguration.minimumDistance,
      ) { payload, phase in

        guard let payload else {
          if phase.isTerminal {
            store.endInteraction(
              .drag,
              phase: phase,
              modifiers: modifiers,
            )
          }
          return
        }

        store.processInteraction(
          .drag(payload),
          phase: phase,
          modifiers: modifiers,
          zoomRange: zoomRange,
        )
        //        apply(adjustment)
      }
  }
}

extension InteractionModifiers {
  private var modifiers: EventModifiers {
    guard let modifierKeys else { return [] }
    return .init(from: modifierKeys)
  }

  //  private func apply(_ adjustment: TransformState?) {
  //    guard var adjustment else { return }
  //    adjustment.scale = adjustment.scale.clamped(to: zoomRange)
  //    store.currentTransform = adjustment
  //  }

  private func isEnabled(
    for interaction: Interaction.Kind
  ) -> Bool {
    let isEnabled: Bool

    switch interaction {
      case .swipe, .pinch, .rotate, .hover:
        isEnabled = true

      case .tap, .drag:
        // Keep the recogniser installed for the tool's interaction kind.
        // CanvasHandler performs event-time modifier matching so a capability
        // can require modifiers without publishing unmatched pointer input.
        isEnabled = store.effectiveTool.inputCapabilities.contains { capability in
          capability.interactionKind == interaction
        }
    }
    return isEnabled
  }
}
