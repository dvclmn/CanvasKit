//
//  ZoomHelpers.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//

import SwiftUI

//struct ZoomAwareStrokeModifier: ViewModifier {
//
//  func body(content: Content) -> some View {
//    content
//  }
//}

private struct ZoomAwareStrokeView<BaseShape: Shape, ContentStyle: ShapeStyle>: View {
  let shape: BaseShape
  let content: ContentStyle
  let effectiveLineWidth: Double
  let antialiased: Bool

  // Read your CanvasKit environment value here
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.zoomRange) private var zoomRange

  var body: some View {
    //    let adjustedWidth = effectiveLineWidth / max(zoomLevel, 0.001) // avoid div by zero

    // Apply the native modifier
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
    // We return our custom private view, hiding the complexity
    ZoomAwareStrokeView(
      shape: self,
      content: content,
      effectiveLineWidth: effectiveLineWidth,
      antialiased: antialiased,
    )
  }

}
