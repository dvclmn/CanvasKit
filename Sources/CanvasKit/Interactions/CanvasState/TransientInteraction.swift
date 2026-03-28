//
//  TransientInteraction.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/3/2026.
//

import Foundation
import InteractionPrimitives

public struct TransientInteraction<Value: Sendable & Equatable>: Sendable, Equatable {
  public var value: Value?
  public var phase: InteractionPhase
//  public var source: InteractionSource

  /// It's active if we have data AND the phase hasn't terminated.
  public var isActive: Bool {
    value != nil && phase.isActive
  }

  public init(
    _ value: Value? = nil,
    phase: InteractionPhase = .none,
//    source: InteractionSource
  ) {
    self.value = value
    self.phase = phase
//    self.source = source
  }

  public mutating func update(
    _ value: Value?,
    phase: InteractionPhase,
//    source: InteractionSource,
  ) {
    self.value = value
    self.phase = phase
//    self.source = source
  }

  /// Instantly clears the transient state.
  public mutating func reset() {
    self.value = nil
    self.phase = .none
  }
}
