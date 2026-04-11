//
//  PanEvent.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import BasePrimitives

public typealias SwipeOutputInternal = (SwipeEvent, Modifiers) -> Void

public struct SwipeEvent {
  public let delta: Size<ScreenSpace>
  public let location: Point<ScreenSpace>
  public let phase: InteractionPhase
}

extension SwipeEvent {
  public var isSwiping: Bool { phase.isActive }
}
