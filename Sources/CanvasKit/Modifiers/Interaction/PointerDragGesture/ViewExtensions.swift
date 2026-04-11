//
//  ViewExtensions.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 13/3/2026.
//

import SwiftUI

extension View {

  // TODO: Manage marqueeColour so it's only exposed where relevant
  /// Event-driven pointer drag gesture.
  ///
  /// The modifier handles gesture mechanics internally:
  /// - **Continuous mode**: each callback delivers a frame-to-frame delta.
  ///   External state changes (e.g. swipe pan) between drags are transparent
  ///   because deltas are always relative, never absolute.
  /// - **Marquee mode**: each callback delivers the rect from drag origin to
  ///   current pointer. The modifier draws the marquee overlay. State is
  ///   cleared on gesture end.
  ///
  /// - Parameters:
  ///   - coordinateSpace: Coordinate space for the underlying `DragGesture`.
  ///   - behaviour: The drag mode (`.continuous`, `.marquee`, or `.none`).
  ///   - marqueeColour: The colour to render the marquee rectangle, if needed.
  ///  - minimumDistance: Minimum drag distance before the gesture activates.
  ///   - didUpdatePayload: Callback receiving the drag payload and phase.
  public func onPointerDragGesture(
    behaviour: PointerDragBehaviour,
    isEnabled: Bool = true,
    coordinateSpace: CoordinateSpace = .local,
    marqueeColour: Color = .accentColor,
    minimumDistance: CGFloat = 5,
    didUpdatePayload: @escaping DragEventUpdate,
  ) -> some View {
    self.modifier(
      PointerDragModifier(
        behaviour: behaviour,
        isEnabled: isEnabled,
        marqueeColour: marqueeColour,
        coordinateSpace: coordinateSpace,
        minimumDistance: minimumDistance,
        didUpdatePayload: didUpdatePayload,
      )
    )
  }
}
