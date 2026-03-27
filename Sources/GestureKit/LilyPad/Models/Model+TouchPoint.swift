//
//  Model+StrokePoint.swift
//  LilyPad
//
//  Created by Dave Coleman on 5/5/2025.
//

import CoreGraphics
import Foundation

/// Example logic for drawing engine
/// ```
/// func calculateWidth(speed: CGFloat) -> CGFloat {
///   let baseWidth: CGFloat = 10.0
///   let sensitivity: CGFloat = 0.001 // Adjust based on View vs Normalized space
///
///   // As speed increases, width drops off exponentially
///   return baseWidth * exp(-speed * sensitivity)
/// }
/// ```
public struct TouchPoint: Identifiable, Hashable {
  public let id: Int  // From NSTouch.identity
  public let position: CGPoint  // View-space or Normalized
  public let velocity: CGVector  // Points per second
  public let magnitude: CGFloat  // Scalar speed
  public let phase: InteractionPhase
  public let isResting: Bool

  public init(
    id: Int,
    position: CGPoint,
    velocity: CGVector,
    magnitude: CGFloat,
    phase: InteractionPhase,
    isResting: Bool = false
  ) {
    self.id = id
    self.position = position
    self.velocity = velocity
    self.magnitude = magnitude
    self.phase = phase
    self.isResting = isResting
  }
}

struct TouchState {
  var lastPosition: CGPoint
  var lastTimestamp: TimeInterval
  var smoothedVelocity: CGVector = .zero
}
