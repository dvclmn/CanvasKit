//
//  InteractionModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/3/2026.
//

import InteractionKit
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
        self.transform = store.processedTransform(
          .swipe(delta: event.delta),
          phase: event.phase,
          currentTransform: transform,
        )
      }

      .onPinchGesture(
        initial: transform.scale,
        isEnabled: isEnabled(.pinch),
      ) { zoom, phase in
        let transformResult = store.processedTransform(
          .pinch(scale: zoom),
          phase: phase,
          currentTransform: transform,
        )
        self.transform = transformResult
        /// Returns the scale so the modifier's internal Zoom
        /// stays in sync with transform state
        return transformResult.scale
      }

      .onContinuousHover(coordinateSpace: .named(ScreenSpace.screen)) { phase in
        guard isEnabled(.hover), let location = phase.location else { return }
        self.transform = store.processedTransform(
          .hover(location.screenPoint),
          phase: phase.interactionPhase,
          currentTransform: transform,
        )
      }

      .onTapGesture(coordinateSpace: .named(ScreenSpace.screen)) { location in
        guard isEnabled(.tap) else { return }
        self.transform = store.processedTransform(
          .tap(location: location.screenPoint),
          phase: .ended,
          currentTransform: transform,
        )
      }

      .onPointerDragGesture(
        behaviour: activeTool?.dragBehaviour ?? .none,
        isEnabled: isEnabled(.drag),
      ) { payload, phase in
        guard let payload else { return }
        self.transform = store.processedTransform(
          .drag(payload),
          phase: phase,
          currentTransform: transform,
        )
      }
  }
}

extension InteractionModifiers {
  private func isEnabled(_ interaction: InteractionKinds.Element) -> Bool {
    guard let tool = store.activeTool else { return false }
    return tool.inputCapabilities.contains(interaction)
  }
}

extension View {
  public func gestureModifiers(_ transform: Binding<TransformState>) -> some View {
    self.modifier(InteractionModifiers(transform: transform))
  }
}
