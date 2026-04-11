//
//  PointerDragModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 14/1/2026.
//

import SwiftUI
import BasePrimitives

/// Callback receiving the drag payload and interaction phase.
public typealias DragEventUpdate = (PointerDragPayload?, InteractionPhase) -> Void

/// A SwiftUI modifier that handles pointer drag gestures, producing either
/// frame-to-frame deltas (continuous mode) or anchor-to-current rects
/// (marquee mode) via an event callback.
///
/// This modifier uses **event-callback mode only** — it does not write to
/// external bindings. The callback is the sole output channel, allowing
/// consumers (e.g. CanvasKit's tool pipeline) to intercept, transform,
/// or discard drag values before they reach state.
///
/// ## Continuous mode
/// Each callback delivers a frame-to-frame delta. External state changes
/// (e.g. swipe pan changing the translation) between drags are transparent
/// because deltas are always relative, never absolute.
///
/// ## Marquee mode
/// Each callback delivers the rect from drag origin to current pointer.
/// The modifier draws a marquee overlay. State is cleared on gesture end.
struct PointerDragModifier: ViewModifier {

  @State private var dragState = DragGestureState()

  /// Local marquee rect for the overlay — only populated in marquee mode.
  @State private var marqueeRect: Rect<ScreenSpace>?

  /// The drag mode passed from the parent (via environment → modifier init).
  /// Stored as a `let` so SwiftUI refreshes it on every re-render, allowing
  /// `onChange(of: behaviour)` to detect tool switches.
  ///
  /// Reminder to self: Do NOT derive this from `dragState.behaviour`
  /// — that creates a circular dependency where `onChange` never fires
  /// because `@State` preserves across re-renders.
  let behaviour: PointerDragBehaviour
  let isEnabled: Bool
  let marqueeColour: Color
  let coordinateSpace: CoordinateSpace
  let minimumDistance: CGFloat
  let didUpdatePayload: DragEventUpdate

  func body(content: Content) -> some View {
    content
      .gesture(dragGesture, isEnabled: behaviour.isEnabled)
      .drawMarqueeRect(
        marqueeRect?.cgRect,
        colour: marqueeColour,
        isEnabled: behaviour.isMarquee,
      )
      .onChange(of: behaviour, initial: true) { _, newValue in
        /// Update `DragGestureState` so it has the right behaviour
        dragState.behaviour = newValue
        dragState.end()
        marqueeRect = nil
      }
  }
}

extension PointerDragModifier {

  private var dragGesture: some Gesture {
    DragGesture(
      minimumDistance: minimumDistance,
      coordinateSpace: coordinateSpace,
    )
    .onChanged { gestureValue in
      let payload = dragState.update(gestureValue)
      if case .rect(let from, let current) = payload {
        marqueeRect = Rect<ScreenSpace>(from: from, to: current)
      }
      didUpdatePayload(payload, .changed)
    }
    .onEnded { gestureValue in
      let payload = dragState.update(gestureValue)
      didUpdatePayload(payload, .ended)
      dragState.end()
      marqueeRect = nil
    }
  }
}
