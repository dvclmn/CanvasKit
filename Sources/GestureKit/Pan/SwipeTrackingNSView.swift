//
//  PanGestureNSView.swift
//  Paperbark
//
//  Created by Dave Coleman on 24/6/2025.
//

#if canImport(AppKit)
import AppKit
//import BasePrimitives

/// Swipe == Pan — avoiding using word Pan directly, as I keep getting
/// confused between Pan the Gesture Kind, and Pan from *other*
/// input methods like click and drag.
public class SwipeTrackingNSView: NSView {
  var onSwipeGesture: SwipeOutputInternal = { _, _ in }

  public override func scrollWheel(with event: NSEvent) {

    let locationInView = convert(event.locationInWindow, from: nil)
    let delta = CGSize(width: event.scrollingDeltaX, height: event.scrollingDeltaY)
    let phase = InteractionPhase(from: event.phase)
    let modifiers = Modifiers(from: event)

    let eventData = SwipeEvent(
      delta: delta.screenSize,
      location: locationInView.screenPoint,
      phase: phase,
//      modifiers: modifiers
    )
    onSwipeGesture(eventData, modifiers)
  }
}
#endif
