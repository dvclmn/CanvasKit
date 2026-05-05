//
//  CanvasHoverModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 22/4/2026.
//

import GeometryPrimitives
import CoreUtilities
import SwiftUI

public struct CanvasHoverModifier: ViewModifier {
  @Environment(\.pointerHover) private var pointerHover
//  @Environment(\.interactionPhase) private var interactionPhase
  
  let action: (CanvasHoverPhase) -> Void
  
  public func body(content: Content) -> some View {
    content
      .onChange(of: pointerHover) {
        guard let pointerHover else {
          printMissing("pointerHover", for: "CanvasHoverModifier")
          return
        }
        action()
      }
  }
}

public enum CanvasHoverPhase {
  /// The pointer's location within the CanvasView, in local CanvasSpace.
  case active(CGPoint)
  
  /// The pointer exited the CanvasView.
  case ended
}
