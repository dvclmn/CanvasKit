//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import InteractionKit
import SwiftUI

public struct CanvasView<Content: View>: View, CanvasAddressable {

  @State private var store: CanvasHandler = .init()
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
