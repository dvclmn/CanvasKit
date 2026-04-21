//
//  Interaction+Env.swift
//  InteractionKit
//
//  Created by Dave Coleman on 28/3/2026.
//

import SwiftUI
import InputPrimitives

/// Bit awkward, but this `interactionPhase` is only here as I'm
/// trying to avoid making CanvasCore depend on InputPrimitives
extension EnvironmentValues {
  @Entry package var interactionPhase: InteractionPhase = .none
}
