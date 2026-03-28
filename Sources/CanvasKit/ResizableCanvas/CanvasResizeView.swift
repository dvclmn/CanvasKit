//
//  CanvasResizeModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 4/8/2025.
//

//import BasePrimitives
import SwiftUI

/// Note: The provided size here does *not* have zoom applied.
public typealias ResizeOutput = (GridBoundaryPoint, CGSize) -> Void

public struct CanvasResizeView: View {
  @Environment(\.panOffset) private var panOffset
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.canvasSize) private var canvasSize
  @Environment(\.zoomRange) private var zoomRange

  @Binding var store: ResizeHandler

  let isEnabled: Bool

  public var body: some View {

    if isEnabled {

      ZStack {
        RoundedRectangle(cornerRadius: Styles.sizeTiny)
          .fill(.clear)
        RoundedRectangle(cornerRadius: Styles.sizeTiny)
          .stroke(
            .blue, lineWidth: Double(1).removingZoom(zoomLevel, across: zoomRange)
          )
//          .frameFromSize(canvasSize?.cgSize.addingZoom(zoomLevel))

        if let transientSize = store.transientCanvasSize {
          Rectangle()
            .fill(.pink.opacityFaint)
            .border(.pink)
//            .frameFromSize(transientSize.addingZoom(zoomLevel))
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
//        .frameFromSize(canvasSize?.cgSize.addingZoom(zoomLevel))

        ControlPointView(
          Circle(),
          point: .center,
          length: store.controlLength * 1.2
        )

      }  // END zstack

      .offset(panOffset)
      .frame(maxWidth: .infinity, maxHeight: .infinity)

    }  // END is Resize allowed
  }
}

extension CanvasResizeView {

}
