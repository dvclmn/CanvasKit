//
//  ContentView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 9/1/2026.
//

import CanvasKit
import SwiftUI
import ToolKit

struct ContentView: View {
  let canvasSize: CGSize = CGSize(1200, 800)
  var body: some View {
    CanvasView(canvasSize: canvasSize, showsInfoBar: true) {
      Circle().fill(.brown.tertiary)
        .padding()
      Text("Hello")
    }

    .background(.blue.quinary)
  }
}

#if DEBUG
#Preview {
  ContentView()
    .frame(minWidth: 400, minHeight: 500)
}
#endif
