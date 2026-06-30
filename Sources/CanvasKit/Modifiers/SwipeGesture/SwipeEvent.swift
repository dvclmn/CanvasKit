//
//  PanEvent.swift
//  CanvasKit
//
//  Created by Dave Coleman on 17/3/2026.
//

import SwiftUI

public typealias SwipeOutput = (SwipeEvent) -> Void
public typealias ViewportSwipeEvent = SwipeEvent
public typealias ViewportSwipeOutput = (ViewportSwipeEvent) -> Void

public struct SwipeEvent {
  public let delta: Size<ViewportSpace>
  public let location: Point<ViewportSpace>
  public let phase: InteractionPhase

  /// Will be added to the environment, but also included
  /// here in case direct access is needed
  public let modifiers: EventModifiers

  public init(
    delta: Size<ViewportSpace>,
    location: Point<ViewportSpace>,
    phase: InteractionPhase,
    modifiers: EventModifiers,
  ) {
    self.delta = delta
    self.location = location
    self.phase = phase
    self.modifiers = modifiers
  }
}

extension SwipeEvent {
  public var isSwiping: Bool { phase.isActive }

  public func matches(requiredModifiers: EventModifiers) -> Bool {
    modifiers.contains(requiredModifiers)
  }
}
