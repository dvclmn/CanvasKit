//
//  CanvasTapModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import GeometryPrimitives
import CoreUtilities
import SwiftUI

public struct CanvasTapModifier: ViewModifier {
  @Environment(\.pointerTap) private var pointerTap

  let action: (Point<CanvasSpace>) -> Void
  
  public func body(content: Content) -> some View {
    content
      .onChange(of: pointerTap) {
        guard let pointerTap else {
          printMissing("pointerTap", for: "CanvasTapModifier")
          return
        }
        action(pointerTap)
      }
  }
}
