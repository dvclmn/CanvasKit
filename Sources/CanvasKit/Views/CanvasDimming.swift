//
//  CanvasDimming.swift
//  CanvasKit
//
//  Created by Dave Coleman on 5/8/2026.
//

import SwiftUI

/// Keeps artwork fully visible inside its bounds while reducing the opacity
/// of any visual overflow that remains visible within the viewport.
struct CanvasDimmingMask: View {
  let cornerRadius: Double
  let dimmingAmount: Double

  private var outsideOpacity: Double { 1 - dimmingAmount }

  var body: some View {
    GeometryReader { proxy in
      if let viewportBounds = proxy.bounds(of: .named(ViewportSpace.viewport)) {
        ZStack {
          ViewportBoundsShape(bounds: viewportBounds)
            .fill(.white.opacity(outsideOpacity))

          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.white)
        }
      } else {
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(.white)
      }
    }
    .allowsHitTesting(false)
  }
}

/// Draws the viewport in the mask's local coordinate space.
///
/// `GeometryProxy.bounds(of:)` performs the coordinate-space conversion, so
/// this path naturally follows the viewport through canvas pan and zoom
/// without an arbitrary outside extent or stored geometry state.
private struct ViewportBoundsShape: Shape {
  let bounds: CGRect

  func path(in _: CGRect) -> Path {
    Path { path in
      path.addRect(bounds)
    }
  }
}
