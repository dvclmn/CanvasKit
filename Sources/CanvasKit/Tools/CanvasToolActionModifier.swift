//
//  CanvasToolActionModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 15/4/2026.
//

import CanvasCore
import SwiftUI

public struct CanvasToolActionModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store

  let action: (ToolAction) -> Void

  public func body(content: Content) -> some View {
    content
      .onChange(of: store.toolActionRevision, initial: false) { _, _ in
        guard let toolAction = store.lastToolAction else { return }
        action(toolAction)
      }
  }
}

extension View where Self: CanvasAddressable {

  /// Respond to a tool-emitted domain action.
  public func onCanvasToolAction(
    perform action: @escaping (ToolAction) -> Void
  ) -> ModifiedContent<Self, CanvasToolActionModifier> {
    self.modifier(CanvasToolActionModifier(action: action))
  }
}
