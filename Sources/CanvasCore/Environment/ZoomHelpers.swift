//
//  ZoomHelpers.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//

import CoreUtilities
import SwiftUI

private struct ZoomAwareStrokeView<BaseShape: Shape, ContentStyle: ShapeStyle>: View {
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.zoomRange) private var zoomRange

  let shape: BaseShape
  let content: ContentStyle
  let effectiveLineWidth: Double
  let antialiased: Bool

  var body: some View {
    shape.stroke(
      content,
      lineWidth: adjustedLineWidth,
      antialiased: antialiased,
    )
  }
}
extension ZoomAwareStrokeView {
  private var adjustedLineWidth: CGFloat {
    effectiveLineWidth.removingZoom(
      zoomLevel,
      across: zoomRange,
      sensitivity: nil,
    )
  }
}

extension Shape {

  func stroke<S: ShapeStyle>(
    _ content: S,
    effectiveLineWidth: CGFloat,
    antialiased: Bool = true,
    //  ) -> StrokeShapeView<Self, S, EmptyView> where S: ShapeStyle {
  ) -> some View {
    ZoomAwareStrokeView(
      shape: self,
      content: content,
      effectiveLineWidth: effectiveLineWidth,
      antialiased: antialiased,
    )
  }

}
