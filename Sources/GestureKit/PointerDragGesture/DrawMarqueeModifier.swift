//
//  DrawMarqueeModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 13/7/2025.
//

import SwiftUI

public struct DrawMarqueeModifier: ViewModifier {
  @Environment(\.isDebugMode) var isDebugMode
  let rect: CGRect?
  let isEnabled: Bool

  public func body(content: Content) -> some View {
    content
      .overlay {
        if isEnabled, let rect {
          ZStack {
            Canvas { context, size in
              context.stroke(rect.path, with: .color(.pink))
            }
            .allowsHitTesting(false)
            .addDebugText(
              "Origin: \(rect.origin.displayString(.concise))",
              isEnabled: isDebugMode
            )
          }
        }  // END rect check, is enabled
      }  // END overlay
  }
}

extension View {
  public func drawMarqueeRect(
    rect: CGRect?,
    isEnabled: Bool
  ) -> some View {
    self.modifier(DrawMarqueeModifier(rect: rect, isEnabled: isEnabled))
  }
}
