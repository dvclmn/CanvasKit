//
//  PanEvent.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//


import GeometryPrimitives
import InputPrimitives

//public typealias SwipeOutputInternal = (SwipeEvent, Modifiers) -> Void
public typealias SwipeOutput = (SwipeEvent) -> Void

public struct SwipeEvent {
  public let delta: Size<ScreenSpace>
  public let location: Point<ScreenSpace>
  public let phase: InteractionPhase
  
  /// Will be added to the environment, but also included
  /// here in case direct access is needed
  public let modifiers: Modifiers
}

extension SwipeEvent {
  public var isSwiping: Bool { phase.isActive }
}
