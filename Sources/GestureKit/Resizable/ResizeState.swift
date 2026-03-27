//
//  ResizeState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 22/2/2026.
//


import SwiftUI

struct ResizeGesture: Gesture {
  @GestureState var dragDelta: CGFloat = 0
  @Binding var currentLength: CGFloat
  let state: ResizeState
  let deltaDidChange: (_ delta: CGFloat) -> Void

  var body: some Gesture {
    DragGesture(minimumDistance: 0, coordinateSpace: .global)
      .updating($dragDelta) { value, gestureState, _ in
        let delta = state.isVertical ? value.translation.height : value.translation.width
        gestureState = delta
        deltaDidChange(delta)
      }
      .onEnded { value in
        let translation = state.isVertical ? value.translation.height : value.translation.width
        let proposed = currentLength + (translation * state.dragMultiplier)
        currentLength = proposed.clamped(to: state.lengthRange)
        deltaDidChange(.zero)
      }
  }
}

struct ResizeState: Equatable {
  let edge: Edge
  let minLength: CGFloat
  let maxLength: CGFloat
}

extension ResizeState {
  package var lengthRange: ClosedRange<CGFloat> {
    minLength...maxLength
  }

  package var isVertical: Bool { edge.isVertical }

  /// Invert drag for Top and Leading edges
  package var dragMultiplier: CGFloat {
    (edge == .top || edge == .leading) ? -1 : 1
  }
  
  package func displaySize(
    currentLength: CGFloat,
    dragDelta: CGFloat
  ) -> CGFloat {
    (currentLength + (dragDelta * dragMultiplier)).clamped(to: lengthRange)
  }

}
