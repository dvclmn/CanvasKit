//
//  TrackpadTouchManager.swift
//  LilyPad
//
//  Created by Dave Coleman on 3/5/2025.
//

import AppKit
//import VectorKit

/// Manages trackpad touches and maintains their history for velocity calculations
class TrackpadTouchManager {
  var smoothingFactor: CGFloat = 0.2

  enum CoordinateSpace {
    case normalized
    case view(CGSize)
  }

  private var history: [Int: TouchState] = [:]

  func processCapturedTouches(
    _ nsTouches: Set<NSTouch>,
    timestamp: TimeInterval,
    in space: CoordinateSpace
  ) -> Set<TouchPoint> {
    var results = Set<TouchPoint>()

    for touch in nsTouches {
      let id = touch.identity.hash

      /// 1. Determine Position
      let currentPos = currentPos(for: touch, in: space)

      /// 2. Calculate Velocity
      var velocity = CGVector.zero

      if let previous = history[id] {
        handlePrevState(
          previous,
          current: currentPos,
          timestamp: timestamp,
          velocity: &velocity
        )
      }

      if touch.phase == .ended || touch.phase == .cancelled {
        history.removeValue(forKey: id)
      } else {
        history[id] = TouchState(
          lastPosition: currentPos,
          lastTimestamp: timestamp,
          smoothedVelocity: velocity
        )
      }

      let magnitude = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)

      let newTouchPoint = TouchPoint(
        id: id,
        position: currentPos,
        velocity: velocity,
        magnitude: magnitude,
        phase: InteractionPhase(from: touch.phase),
        isResting: touch.isResting
      )

      results.insert(newTouchPoint)
    }

    return results
  }

  private func handlePrevState(
    _ previousState: TouchState,
    current currentPosition: CGPoint,
    timestamp: TimeInterval,
    velocity: inout CGVector,
  ) {
    let dt = CGFloat(timestamp - previousState.lastTimestamp)

    if dt > 0 {
      velocity = CGVector.smoothed(
        previous: previousState.smoothedVelocity,
        prevPosition: previousState.lastPosition,
        currentPosition: currentPosition,
        factor: smoothingFactor,
        dt: dt
      )
    }
  }

  private func currentPos(
    for touch: NSTouch,
    in space: CoordinateSpace
  ) -> CGPoint {
    let normalised = touch.normalizedPosition
    return switch space {
      case .normalized:
        normalised

      case .view(let size):
        CGPoint(
          x: size.width * normalised.x,
          y: size.height * (1 - normalised.y)
        )
    }
  }
}
