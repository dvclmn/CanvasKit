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
  @Environment(\.modifierKeys) private var modifierKeys

  @Binding var transform: TransformState
  let tool: (any CanvasTool)?

  func body(content: Content) -> some View {
    @Bindable var store = store

    content
      .onSwipeGesture(
        isEnabled: isEnabled(.swipe)
      ) { event in

        let adjustment = store.processedTransform(
          .swipe(delta: event.delta),
          tool: tool,
          phase: event.phase,
          modifiers: event.modifiers,
          currentTransform: transform,
        )
        guard let adjustment else { return }
        self.transform = adjustment

        print("Adjustment: \(adjustment)")
      }

      .onPinchGesture(
        initial: transform.scale,
        isEnabled: isEnabled(.pinch),
      ) { zoom, phase in

        let adjustment = store.processedTransform(
          .pinch(scale: zoom),
          tool: tool,
          phase: phase,
          modifiers: modifierKeys,
          currentTransform: transform,
        )

        /// Returns the scale so the modifier's internal Zoom
        /// stays in sync with transform state
        guard let adjustment else {
          return adjustment?.scale
        }
        self.transform = adjustment
        return adjustment.scale

      }

      .onContinuousHover(coordinateSpace: .named(ScreenSpace.screen)) { phase in
        guard isEnabled(.hover), let location = phase.location else { return }
        let adjustment = store.processedTransform(
          .hover(location.screenPoint),
          tool: tool,
          phase: phase.interactionPhase,
          modifiers: modifierKeys,
          currentTransform: transform,
        )
        guard let adjustment else { return }
        self.transform = adjustment

      }

      .onTapGesture(coordinateSpace: .named(ScreenSpace.screen)) { location in
        guard isEnabled(.tap) else { return }
        let adjustment = store.processedTransform(
          .tap(location: location.screenPoint),
          tool: tool,
          phase: .ended,
          modifiers: modifierKeys,
          currentTransform: transform,
        )
        guard let adjustment else { return }
        self.transform = adjustment

      }

      .onPointerDragGesture(
        behaviour: tool?.dragBehaviour ?? .none,
        isEnabled: isEnabled(.drag),
      ) { payload, phase in
        guard let payload else { return }
        let adjustment = store.processedTransform(
          .drag(payload),
          tool: tool,
          phase: phase,
          modifiers: modifierKeys,
          currentTransform: transform,
        )
        guard let adjustment else { return }
        self.transform = adjustment
      }
  }
}

extension InteractionModifiers {
  private func isEnabled(_ interaction: InteractionKinds.Element) -> Bool {
    /// No need to gate any modifiers if Tools are not active
    guard store.areToolsInUse else {
      let tool = self.tool ?? .default
      return tool.inputCapabilities.contains(interaction)
    }
    return true
  }
}

//extension View {
//  public func gestureModifiers(_ transform: Binding<TransformState>) -> some View {
//    self.modifier(InteractionModifiers(transform: transform))
//  }
//}
