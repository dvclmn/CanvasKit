//
//  ContinuousInteraction.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/3/2026.
//

import Foundation
import InteractionPrimitives

/// E.g. Used for Swipe gesture (Pan), Pinch gesture (Zoom)
/// Of note: Holds a non-optional Value, because a `ContinuousInteraction`
/// property has a resting/idle/neutral value, such as Pan having `.zero` offset
public struct ContinuousInteraction<Value: Sendable & Equatable>: Equatable, Sendable {
  public var value: Value
  public var phase: InteractionPhase
  //  public var source: InteractionSource

  public var isActive: Bool { phase.isActive }

}

extension ContinuousInteraction {

  public init(
    _ value: Value,
    phase: InteractionPhase = .none,
    //    source: InteractionSource,
  ) {
    self.value = value
    self.phase = phase
    //    self.source = source
  }

  public mutating func update(
    _ value: Value,
    phase: InteractionPhase,
    //    source: InteractionSource,
  ) {
    self.value = value
    self.phase = phase
    //    self.source = source
  }

}
