//
//  CanvasTapModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import InteractionKit
import SwiftUI

struct CanvasTapModifier: ViewModifier {
  @Environment(\.pointerTap) private var pointerTap

  let action: (Point<CanvasSpace>) -> Void
  
  func body(content: Content) -> some View {
    content
      .onChange(of: pointerTap) {
        guard let pointerTap else { return }
        action(pointerTap)
      }
  }
}
