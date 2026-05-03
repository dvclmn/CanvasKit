//
//  ContentView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 9/1/2026.
//

import CanvasKit
import GeometryPrimitives
import SwiftUI

enum Constants {
  static let canvasSize: CGSize = CGSize(width: 380, height: 300)
}

struct ContentView: View {
  @State private var transform: TransformState
  @State private var toolConfiguration: ToolConfiguration

  init(
    transform: TransformState = .init(),
    toolConfiguration: ToolConfiguration = .default,
  ) {
    self._transform = State(initialValue: transform)
    self._toolConfiguration = State(initialValue: toolConfiguration)
  }

  var body: some View {

    CanvasView(
      size: Constants.canvasSize,
      transform: $transform,
      toolConfiguration: $toolConfiguration,
    ) {
      CanvasContentView()
        .canvasClipped(true)
    }
    .zoomRange(0.1...20)
    .toolPicker()

    //    .onAppear {
    //      transform.scale = 1.8
    //      transform.translation.width = -90
    //    }
  }
}

#if DEBUG
#Preview {
  @Previewable @State var transform = TransformState()
  @Previewable @State var toolConfiguration = ToolConfiguration()

  ContentView(
    transform: transform,
    toolConfiguration: toolConfiguration,
  )

  .frame(minWidth: 400, minHeight: 500)

}
#endif
