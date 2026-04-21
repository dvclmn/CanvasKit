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
  @State private var transform: CanvasState = .init()
  @State private var toolConfiguration = ToolConfiguration()
  var body: some View {

    CanvasView(
      size: canvasSize,
      state: transform,
      toolConfiguration: $toolConfiguration,
    ) {
      //    CanvasView(
      //      size: canvasSize,
      //      transform: $transform,
      //      toolConfiguration: $toolConfiguration
      //    ) {
      Canvas { context, size in
        context.fill(
          Path(
            ellipseIn: CGRect(origin: .zero, size: CGSize(width: 200, height: 100))
          ),
          with: .color(.blue),
        )
      }
    }
    .zoomRange(0...2)
    .onCanvasToolAction { action in
      print("Tool action: \(action)")
    }

  }
}

#if DEBUG
#Preview {
  ContentView()
    .frame(minWidth: 400, minHeight: 500)
}
#endif
