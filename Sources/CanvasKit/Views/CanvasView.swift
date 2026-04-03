//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import GeometryPrimitives
import InteractionPrimitives
import SwiftUI

public struct CanvasView<Content: View>: View, ZoomRangeProvidable {

  let canvasSize: Size<CanvasSpace>
  @Binding var toolHandler: ToolHandler
  let content: () -> Content

  public init(
    size: CGSize,  // Canvas size
    toolHandler: Binding<ToolHandler> = .constant(.init()),
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = Size<CanvasSpace>(fromCGSize: size)
    self._toolHandler = toolHandler
    self.content = content
  }

  public var body: some View {

    CanvasCoreView(canvasSize: canvasSize, content: content)

      .modifier(
        InteractionStateSetupModifier(
          toolHandler: $toolHandler,
          canvasSize: canvasSize,
        )
      )
  }
}

public protocol ZoomRangeProvidable {}

extension View where Self: ZoomRangeProvidable {
  public func zoomRange(_ range: ClosedRange<Double>) -> some View {
    self.environment(\.zoomRange, range)
  }
}
