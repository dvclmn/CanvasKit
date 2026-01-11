//
//  CanvasResizeModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 4/8/2025.
//

import BasePrimitives
import SwiftUI

/// Note: The provided size here does *not* have zoom applied.
public typealias ResizeOutput = (GridBoundaryPoint, CGSize) -> Void

public struct CanvasResizeView: View {
  @Environment(\.canvasPan) private var canvasPan
  @Environment(\.canvasZoom) private var canvasZoom
  @Environment(\.canvasSize) private var canvasSize
  @Environment(\.canvasZoomRange) private var canvasZoomRange

  @Binding var store: ResizeHandler

  let isEnabled: Bool

  public var body: some View {

    if isEnabled {

      ZStack {
        RoundedRectangle(cornerRadius: Styles.sizeTiny)
          .fill(.clear)
        RoundedRectangle(cornerRadius: Styles.sizeTiny)
          .stroke(
            .blue, lineWidth: CGFloat(1).removingZoom(canvasZoom, clampedTo: canvasZoomRange)
          )
          .frameFromSize(canvasSize.addingZoom(canvasZoom))

        if let transientSize = store.transientCanvasSize {
          Rectangle()
            .fill(.pink.opacityFaint)
            .border(.pink)
            .frameFromSize(transientSize.addingZoom(canvasZoom))
        }

        //          ForEach([ResizePoint.bottomLeading]) { point in
        ForEach(GridBoundaryPoint.allCases) { point in
          Rectangle()
            .fill(.clear)
            .modifier(
              HitAreaRectModifier(
                store: $store,
                controlPoint: point.toUnitPoint,
              )
            )
        }  // END foreach

        /// The hit areas need a stable positioning so they don't move
        /// during a drag?
        .frameFromSize(canvasSize.addingZoom(canvasZoom))

        ControlPointView(
          Circle(),
          point: .center,
          length: store.controlLength * 1.2
        )

      }  // END zstack

      .offset(canvasPan)
      .frame(maxWidth: .infinity, maxHeight: .infinity)

    }  // END is Resize allowed
  }
}

extension CanvasResizeView {

}
