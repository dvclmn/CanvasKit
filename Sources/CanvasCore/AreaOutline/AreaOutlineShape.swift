//
//  AreaOutlineShape.swift
//  BasePrimitives
//
//  Created by Dave Coleman on 7/4/2026.
//

import SwiftUI

public struct AreaOutlineShape: View {
  @Environment(\.self) private var env

  let outline: AreaOutline

  public init(_ outline: AreaOutline) {
    self.outline = outline
  }

  public init(
    colour: Color = .white.opacity(0.07),
    rounding: Double = 4,
    lineWidth: Double = 1,
  ) {
    self.outline = AreaOutline(
      colour: colour,
      rounding: rounding,
      lineWidth: lineWidth,
    )
  }

  public var body: some View {
    RoundedRectangle(cornerRadius: outline.resolvedOutline(in: env).rounding)
      .fill(.clear)
      .stroke(
        outline.colour,
        lineWidth: outline.resolvedOutline(in: env).width,
      )
      .allowsHitTesting(false)
  }
}
