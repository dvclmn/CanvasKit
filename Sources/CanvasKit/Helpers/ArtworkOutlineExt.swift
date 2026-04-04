//
//  ArtworkOutline.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//

import SwiftUI

extension EnvironmentValues {
  @Entry var canvasArtworkOutline: ArtworkOutline = .init()
}

extension View where Self: CanvasAddressable {

  public func artworkOutline(
    rounding: CGFloat = 4,
    colour: Color = .white.opacity(0.07),
    lineWidth: CGFloat = 1,
  ) -> some View {
    self.environment(
      \.canvasArtworkOutline,
      .init(
        rounding: rounding,
        colour: colour,
        lineWidth: lineWidth,
      ),
    )
  }
}

/// Rounding and line width remain fixed regardless of zoom
struct ArtworkOutline {
  let rounding: CGFloat
  let colour: Color
  let lineWidth: CGFloat

  init(
    rounding: CGFloat = 4,
    colour: Color = .white.opacity(0.07),
    lineWidth: CGFloat = 1,
  ) {
    self.rounding = rounding
    self.colour = colour
    self.lineWidth = lineWidth
  }
}
