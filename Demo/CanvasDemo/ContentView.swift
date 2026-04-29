//
//  ContentView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 9/1/2026.
//

import CanvasKit
import SwiftUI

struct ContentView: View {
  let canvasSize: CGSize = CGSize(width: 380, height: 300)
  @State private var transform: TransformState = .init()
  @State private var toolConfiguration = ToolConfiguration()
  var body: some View {

    CanvasView(
      size: canvasSize,
      transform: $transform,
//      state: transform,
      toolConfiguration: $toolConfiguration,
    ) {
      CanvasContentView()
    }
    .zoomRange(0...2)

  }
}

#if DEBUG
#Preview {
  ContentView()
    .frame(minWidth: 400, minHeight: 500)
}
#endif

