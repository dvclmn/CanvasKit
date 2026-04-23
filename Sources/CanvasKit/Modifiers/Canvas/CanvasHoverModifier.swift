//
//  CanvasHoverModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 22/4/2026.
//

import GeometryPrimitives
import SwiftUI

public struct CanvasHoverModifier: ViewModifier {
  @Environment(\.pointerHover) private var pointerHover
  @Environment(\.interactionPhase) private var interactionPhase
  
  let action: (Point<CanvasSpace>) -> Void
  
  public func body(content: Content) -> some View {
    content
      .onChange(of: pointerHover) {
        guard let pointerHover else { return }
        action(pointerHover)
      }
  }
}

extension View {

  /// Respond to a `CanvasView` pointer hover operation.
  public func onCanvasHover(
    perform action: @escaping (Point<CanvasSpace>) -> Void
  ) -> ModifiedContent<Self, CanvasHoverModifier> {
    self.modifier(CanvasHoverModifier(action: action))
  }
}
