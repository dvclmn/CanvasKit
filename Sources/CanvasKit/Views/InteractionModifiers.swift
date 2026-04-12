//
//  InteractionModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/3/2026.
//

//import InteractionKit
import BasePrimitives
import SwiftUI

struct InteractionModifiers: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.activeTool) private var activeTool
  @Environment(\.modifierKeys) private var modifierKeys

  @Binding var transform: TransformState

  func body(content: Content) -> some View {
    @Bindable var store = store

    content
      .onSwipeGesture(
        isEnabled: isEnabled(.swipe)
      ) { event in

        let adjustment = store.processedTransform(
          .swipe(delta: event.delta),
          tool: activeTool,
          phase: event.phase,
          currentTransform: transform,
        )
        guard let adjustment else { return }
        self.transform = adjustment

      }

      .onPinchGesture(
        initial: transform.scale,
        isEnabled: isEnabled(.pinch),
      ) { zoom, phase in

        let adjustment = store.processedTransform(
          .pinch(scale: zoom),
          tool: activeTool,
          phase: phase,
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
          tool: activeTool,
          phase: phase.interactionPhase,
          currentTransform: transform,
        )
        guard let adjustment else { return }
        self.transform = adjustment

      }

      .onTapGesture(coordinateSpace: .named(ScreenSpace.screen)) { location in
        guard isEnabled(.tap) else { return }
        let adjustment = store.processedTransform(
          .tap(location: location.screenPoint),
          tool: activeTool,
          phase: .ended,
          currentTransform: transform,
        )
        guard let adjustment else { return }
        self.transform = adjustment

      }

      .onPointerDragGesture(
        behaviour: activeTool?.dragBehaviour ?? .none,
        isEnabled: isEnabled(.drag),
      ) { payload, phase in
        guard let payload else { return }
        let adjustment = store.processedTransform(
          .drag(payload),
          tool: activeTool,
          phase: phase,
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
      let tool = activeTool ?? .default
      return tool.inputCapabilities.contains(interaction)
    }
    return true
  }
}

extension View {
  public func gestureModifiers(_ transform: Binding<TransformState>) -> some View {
    self.modifier(InteractionModifiers(transform: transform))
  }
}
