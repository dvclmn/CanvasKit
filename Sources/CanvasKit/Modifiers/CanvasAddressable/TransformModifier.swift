//
//  TransformModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 25/4/2026.
//

import SwiftUI

/// A convenience for users to add zoom/pan/rotation to the Environment
/// somewhere higher in the View hierarchy than CanvasView.
/// This must be done when using CanvasView's *external*
/// canvas state init.
public struct TransformModifier: ViewModifier {
  
  let canvasState: CanvasState
  let zoomRange: ClosedRange<Double>
  
  public func body(content: Content) -> some View {
    content
    
  }
}

extension View where Self: CanvasAddressable {
//  public func canvasBackground(
//    _ colour: Color
//  ) -> ModifiedContent<Self, CanvasBackgroundModifier> {
//    self.modifier(CanvasBackgroundModifier(background: colour))
//  }
}
