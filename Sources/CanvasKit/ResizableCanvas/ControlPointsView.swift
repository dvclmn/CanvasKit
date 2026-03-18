//
//  ArtboardControlPointView.swift
//  DrawString
//
//  Created by Dave Coleman on 30/7/2025.
//

import SwiftUI

/// Note: Correct alignment (based on unit point) is handled outside
/// this view, via the `overlay` alignment argument. No need
/// for full-width/height frame with alignment assigned, in here.
struct ControlPointView<S: Shape>: View {
  let shape: S
  let point: UnitPoint
  let strokeWidth: CGFloat
  let length: CGFloat
  let isHovered: Bool
  
  init(
    _ shape: S = Rectangle(),
    point: UnitPoint,
    length: CGFloat,
    strokeWidth: CGFloat = 1.0,
    isHovered: Bool = false
  ) {
    self.shape = shape
    self.point = point
    self.strokeWidth = strokeWidth
    self.length = length
    self.isHovered = isHovered
  }

  var body: some View {
    shape
      .fill(isHovered ? .blue : .white)

    shape
      .stroke(
        isHovered ? .cyan : .blue,
        lineWidth: strokeWidth
      )
//      .frameFromLength(length, axis: [.horizontal, .vertical])
      .offset(point.offset(by: -length / 2))
      .allowsHitTesting(false)
  }
}
