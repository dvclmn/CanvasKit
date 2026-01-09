//
//  ContentView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 9/1/2026.
//

import SwiftUI
import CanvasKit
internal import SharedHelpers

struct ContentView: View {
  @State private var canvasHandler = CanvasHandler()

  var body: some View {
    CanvasView(handler: $canvasHandler) {
      ZStack {
        Circle().fill(.brown.tertiary)
          .padding()
        Text("Hello")
      }
    }

    .background(.blue.quinary)
  }
}

#if DEBUG
#Preview {
  ContentView()
    .frame(minWidth: 660, minHeight: 500)
}
#endif
