//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import GeometryPrimitives
import InteractionPrimitives
import SwiftUI

public struct CanvasView<Content: View>: View {
  //  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.zoomRange) private var zoomRange

  @State private var interactionState: CanvasInteractionState = .init()
  //  @Environment(\.shouldShowInfoBarItems) private var shouldShowInfoBarItems

  let canvasSize: Size<CanvasSpace>
  @Binding var toolHandler: ToolHandler
  let content: () -> Content

  public init(
    canvasSize: Size<CanvasSpace>,
    toolHandler: Binding<ToolHandler> = .constant(.init()),
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = canvasSize
    self._toolHandler = toolHandler
    self.content = content
  }

  public init(
    canvasSize: CGSize,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.init(canvasSize: .init(fromCGSize: canvasSize), content: content)
  }

  public var body: some View {

    CanvasCoreView(content: content)

      /// This is passed in via the CanvasView initialiser. Adding it to the Env here.
      .environment(\.canvasSize, canvasSize)
      .task(id: zoomRange) { interactionState.zoomRange = zoomRange }

      .modifier(
        InteractionStateSetupModifier(
          state: interactionState,
          toolHandler: $toolHandler,
          canvasSize: canvasSize,
        )
      )

  }
}

//extension CanvasView {
//
//  @DisplayStringBuilder
//  private func InfoItems(
//    _ zoomRange: ClosedRange<Double>
//  ) -> [DisplayBlock] {
//    if shouldShowInfoBarItems {
//
//      Labeled(
//        "Zoom",
//        value: interactionState.transform.zoom.value
//          .toPercentString(within: zoomRange.toCGFloatRange)
//      )
//
//    }
//  }
//}
