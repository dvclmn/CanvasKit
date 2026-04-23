//
//  DrawMarqueeModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 13/7/2025.
//

import SwiftUI

public struct DrawMarqueeModifier: ViewModifier {
  
  let rect: CGRect?
  let colour: Color
  let isEnabled: Bool

  public func body(content: Content) -> some View {
    content
      .overlay {
        if isEnabled, let rect {
          ZStack {
            Canvas { context, _ in
              context.stroke(Path(rect), with: .color(colour))
            }
            .allowsHitTesting(false)
          }
        }
      }  // END overlay
  }
}

extension View {
  public func drawMarqueeRect(
    _ rect: CGRect?,
    colour: Color = .accentColor,
    isEnabled: Bool
  ) -> some View {
    self.modifier(
      DrawMarqueeModifier(
        rect: rect,
        colour: colour,
        isEnabled: isEnabled
      )
    )
  }
}
