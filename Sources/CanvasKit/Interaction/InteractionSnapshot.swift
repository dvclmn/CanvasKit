//
//  InteractionSnapshot.swift
//  CanvasKit
//
//  Created by Dave Coleman on 30/6/2026.
//

struct InteractionSnapshot: Sendable {
  let kind: Interaction.Kind?
  let phase: InteractionPhase

  static let none: Self = .init(kind: nil, phase: .none)

  init(
    kind: Interaction.Kind?,
    phase: InteractionPhase,
  ) {
    self.kind = kind
    self.phase = phase
  }

  init(context: InteractionContext) {
    self.init(
      kind: context.interaction.kind,
      phase: context.phase,
    )
  }

  func phase(for kind: Interaction.Kind) -> InteractionPhase? {
    guard self.kind == kind else { return nil }
    return phase
  }
}
