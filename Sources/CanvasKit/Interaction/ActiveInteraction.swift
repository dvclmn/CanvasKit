//
//  ActiveInteraction.swift
//  CanvasKit
//
//  Created by Dave Coleman on 30/6/2026.
//

struct ActiveInteraction: Sendable {
  private let contextsByKind: [Interaction.Kind: InteractionContext]

  static let none: Self = .init(contextsByKind: [:])

  init(contextsByKind: [Interaction.Kind: InteractionContext]) {
    self.contextsByKind = contextsByKind
  }

  var isActive: Bool { !contextsByKind.isEmpty }

  var kinds: [Interaction.Kind] {
    Interaction.Kind.allCases.filter { contextsByKind[$0] != nil }
  }

  func contains(_ kind: Interaction.Kind) -> Bool {
    contextsByKind[kind] != nil
  }

  func context(for kind: Interaction.Kind) -> InteractionContext? {
    contextsByKind[kind]
  }

  func phase(for kind: Interaction.Kind) -> InteractionPhase? {
    context(for: kind)?.phase
  }
}
