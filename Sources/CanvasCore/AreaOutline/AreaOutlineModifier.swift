//
//  AreaOutlineModifier.swift
//  BasePrimitives
//
//  Created by Dave Coleman on 5/4/2026.
//

import SwiftUI


struct AreaOutlineModifier: ViewModifier {
  @Environment(\.self) private var env

  let outline: AreaOutline

  func body(content: Content) -> some View {
    content
      .overlay { AreaOutlineShape(outline) }
  }
}

extension View {
  public func areaOutline(
    colour: Color = .white.opacity(0.07),
    rounding: Double = 4,
    lineWidth: Double = 1,
  ) -> some View {
    self.modifier(
      AreaOutlineModifier(
        outline: .init(
          colour: colour,
          rounding: rounding,
          lineWidth: lineWidth,
        )
      )
    )
  }
}
