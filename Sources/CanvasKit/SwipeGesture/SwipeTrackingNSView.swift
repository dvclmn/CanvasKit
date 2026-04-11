//
//  PanGestureNSView.swift
//  Paperbark
//
//  Created by Dave Coleman on 24/6/2025.
//

#if canImport(AppKit)
import AppKit
import BasePrimitives

/// Chose the word Swipe instead of Pan:
///
/// - To signal that this gesture can/should be useful outside of just Panning
/// - I was getting confused when trying to model Interactions, Gesture, State
///   etc for CanvasKit and InteractionKit. Removing the word Pan helped
class SwipeTrackingNSView: NSView {
  var onSwipeGesture: SwipeOutputInternal?

  override func scrollWheel(with event: NSEvent) {
    let locationInView = convert(event.locationInWindow, from: nil)
    let delta = CGSize(width: event.scrollingDeltaX, height: event.scrollingDeltaY)
    let phase = InteractionPhase(from: event.phase)
    let modifiers = Modifiers(from: event)

    let eventData = SwipeEvent(
      delta: delta.screenSize,
      location: locationInView.screenPoint,
      phase: phase,
    )
    onSwipeGesture?(eventData, modifiers)
  }
}
#endif
