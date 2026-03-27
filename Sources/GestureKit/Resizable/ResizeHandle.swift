//
//  ResizeHandle.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 22/2/2026.
//

import SwiftUI

struct ResizeHandle: View {
  @Environment(\.layoutAxis) private var layoutAxis
  private let handleThickness: CGFloat = 20

  @State private var isHovering: Bool = false

  var body: some View {

    ZStack {
      Color.clear
        .contentShape(Rectangle())
        .frame(
          width: isVertical ? nil : handleThickness,
          height: isVertical ? handleThickness : nil
        )
        .onHover { isHovering = $0 }

      /// Visual drag indicator
      Capsule()
        .fill(Color.secondary.opacity(isHovering ? 0.9 : 0.4))
        //        .fill(.thinMaterial)
        .frame(
          width: isVertical ? 40 : 4,
          height: isVertical ? 4 : 40
        )
        .allowsHitTesting(false)
    }
    .pointerStyleCompatible(isVertical ? .rowResize : .columnResize)
    .animation(Styles.animationSmooth, value: isHovering)

  }

}

extension ResizeHandle {
  private var isVertical: Bool {
    layoutAxis?.isVertical ?? false
  }
}
