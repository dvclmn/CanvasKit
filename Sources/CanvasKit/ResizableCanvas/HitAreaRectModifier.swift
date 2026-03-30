//
//  FrameFromUnitPointModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 30/7/2025.
//

import InteractionPrimitives
//import BasePrimitives
import SwiftUI

public struct HitAreaRectModifier: ViewModifier {

  //  @Environment(\.isDebugMode) private var isDebugMode

  private let isDebugMode: Bool = false

  @State private var isHovering: Bool = false
  private let shouldIncludeCorners: Bool = true

  @Binding var store: ResizeHandler
  let controlPoint: UnitPoint

  public func body(content: Content) -> some View {

    content
      .overlay(alignment: controlPoint.toAlignment) {

        Rectangle()
          .fill(.clear)
          .frame(
            maxWidth: layout.fillSizeMax.width,
            maxHeight: layout.fillSizeMax.height,
          )
          .background(rectColour.opacity(0.4))
          .border(rectColour)

          .onHover { hovering in
            guard !store.isDragging else { return }
            isHovering = hovering
          }
          .pointerStyleCompatible(controlPoint.toCompatPointerStyle)
          //          .pointerStyleCompatible(resizePoint.toCompatPointerStyle)
          .modifier(
            ResizeDragModifier(
              store: $store,
              draggedPoint: controlPoint,
            )
          )
          .padding(layout.edgePadding)
          .offset(layout.rectOffset)
          .overlay(alignment: controlPoint.toAlignment) {
            ControlPointView(
              point: controlPoint,
              length: store.controlLength,
              strokeWidth: store.controlStrokeWeight,
              isHovered: isHovering,
            )
          }
      }

  }
}
extension HitAreaRectModifier {

  //  private var resizePoint: GridBoundaryPoint {
  //    GridBoundaryPoint(fromUnitPoint: controlPoint)
  //  }

  private var rectColour: Color {
    let colour = controlPoint.debugColour
    switch (isDebugMode, isHovering) {
      case (true, false): return colour.opacity(0.2)
      case (true, true): return colour
      case (false, _): return .clear
    }
  }

  var layout: HitAreaLayout {
    return HitAreaLayout(
      controlPoint: controlPoint,
      thickness: store.hitAreaThickness,
      offset: store.boundaryOffset,
      shouldIncludeCorners: shouldIncludeCorners,
    )
  }
}
