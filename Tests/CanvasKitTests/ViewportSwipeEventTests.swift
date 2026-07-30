//
//  ViewportSwipeEventTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 30/6/2026.
//

import SwiftUI
import Testing

@testable import CanvasKit

struct ViewportSwipeEventTests {

  @Test func emptyRequiredModifiersMatchesAnyEvent() {
    let event = makeEvent(modifiers: .option)

    #expect(event.matches(requiredModifiers: []))
  }

  @Test func requiredModifiersMatchAsSubset() {
    let event = makeEvent(modifiers: [.option, .shift])

    #expect(event.matches(requiredModifiers: .option))
  }

  @Test func missingRequiredModifiersDoNotMatch() {
    let event = makeEvent(modifiers: .shift)

    #expect(!event.matches(requiredModifiers: .option))
  }

  private func makeEvent(
    modifiers: EventModifiers
  ) -> SwipeEvent {
    .init(
      delta: .zero,
      location: .zero,
      phase: .changed,
      modifiers: modifiers,
    )
  }
}
