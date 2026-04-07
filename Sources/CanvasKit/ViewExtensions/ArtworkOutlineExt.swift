//
//  ArtworkOutline.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//

@_spi(Internals) import BasePrimitives
import SwiftUI

public struct ArtworkOutlineModifier: ViewModifier {
  let colour: Color
  let rounding: Double
  let lineWidth: Double

  public func body(content: Content) -> some View {
    content.environment(
      \.areaOutline,
      AreaOutline(
        colour: colour,
        rounding: rounding,
        lineWidth: lineWidth,
      ),
    )
  }
}
