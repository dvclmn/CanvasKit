//
//  Interaction.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 16/3/2026.
//

/// See also ``InteractionSource``
public struct Interaction {

  /// The interaction 'payload'
  public var source: InteractionSource
  public var geometry: CanvasGeometry
  public var phase: InteractionPhase
  public var modifiers: Modifiers

  public init(
    source: InteractionSource,
    geometry: CanvasGeometry,
    phase: InteractionPhase,
    modifiers: Modifiers,
  ) {
    self.source = source
    self.geometry = geometry
    self.phase = phase
    self.modifiers = modifiers
  }
}
