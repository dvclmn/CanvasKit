//
//  CanvasTapModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import BasePrimitives
import SwiftUI

public struct CanvasTapModifier: ViewModifier {
  @Environment(\.pointerTap) private var pointerTap

  let action: (Point<CanvasSpace>) -> Void
  
  public func body(content: Content) -> some View {
    content
      .onChange(of: pointerTap) {
        guard let pointerTap else { return }
        action(pointerTap)
      }
  }
}

extension View {
//extension View where Self: CanvasAddressable {
  
  /// Respond to `CanvasView` pointer taps. Provides the
  /// location of the tap in `CanvasSpace`.
  public func onCanvasTap(
    perform action: @escaping (Point<CanvasSpace>) -> Void
  ) -> ModifiedContent<Self, CanvasTapModifier> {
    self.modifier(CanvasTapModifier(action: action))
  }

}
