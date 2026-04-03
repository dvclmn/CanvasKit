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
    size: Size<CanvasSpace>,
    toolHandler: Binding<ToolHandler> = .constant(.init()),
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = size
    self._toolHandler = toolHandler
    self.content = content
  }

  public init(
    size: CGSize,  // Canvas size
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.init(size: .init(fromCGSize: size), content: content)
  }

  public var body: some View {

    CanvasCoreView(content: content)

      /// Canvas size is passed in via the initialiser. Adding it to the Env here.
      .environment(\.canvasSize, canvasSize)

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
