//
//  CanvasToolKeyboardModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 15/4/2026.
//

import SwiftUI
private import ViewTools

struct CanvasToolKeyboardModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store

  @FocusState private var isFocused: Bool
  @State private var springLoadArmingTask: Task<Void, Never>?

  func body(content: Content) -> some View {
    content
      // A canvas may receive keyboard focus through user interaction, but appearing during a
      // SwiftUI update must not displace an active editor or other first responder.
      .focusable(true)
      .focused($isFocused)
      .focusEffectDisabled()
      .onKeyPress(
        keys: store.toolHandler.keysToWatch,
        phases: .all,
      ) { result in

        switch result.phase {
          case .up:
            store.toolHandler.handleKeyUp(result.key)
            schedulePendingSpringLoadArming()

          case .down:
            store.toolHandler.handleKeyDown(result.key)
            schedulePendingSpringLoadArming()
          default: break
        }

        return .handled
      }
      .onDisappear {
        springLoadArmingTask?.cancel()
      }
//      .debugText("Is CanvasView focused? \(isFocused)")
  }
}

extension CanvasToolKeyboardModifier {

  /// Schedules delayed arming for pending `.sticky` shortcuts.
  ///
  /// `.hold` shortcuts, such as Space → Pan, are already armed immediately in
  /// `ToolHandler.handleKeyDown(_:)`. This timer only exists for sticky
  /// shortcuts that should commit on quick release but revert after a long hold.
  private func schedulePendingSpringLoadArming() {
    springLoadArmingTask?.cancel()

    guard let delay = store.toolHandler.pendingSpringLoadArmingDelay else {
      springLoadArmingTask = nil
      return
    }

    let nanoseconds = UInt64(max(0, delay) * 1_000_000_000)
    springLoadArmingTask = Task { @MainActor in
      try? await Task.sleep(nanoseconds: nanoseconds)
      guard !Task.isCancelled else { return }

      store.toolHandler.armPendingSpringLoads()
      schedulePendingSpringLoadArming()
    }
  }
}

extension View {
  func onCanvasToolKeyboardPress() -> some View {
    self.modifier(CanvasToolKeyboardModifier())
  }
}
