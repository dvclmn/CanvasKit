//
//  ToolsView.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/4/2026.
//

import SwiftUI

struct ToolsView: View {
  @Environment(CanvasHandler.self) private var store

  private let toolbarWidth: Double = 36

  var body: some View {

    VStack(spacing: 6) {

      if let configuration = store.toolHandler.configuration {
        MainTools(configuration)
      }

      Divider()
        .frame(width: toolbarWidth * 0.7)

      VStack(alignment: .leading) {
        Group {
          Button {
            store.currentTransform.scale = 1.0
            store.currentTransform.translation = .zero

          } label: {
            Label("Re-centre artwork", systemImage: "viewfinder")
              .opacity(0.7)
          }
        }
        .frame(width: toolbarWidth, height: toolbarWidth)

      }  // END main vstack

    }  // END main vstack
    .buttonStyle(.plain)
    .labelStyle(.iconOnly)
    .glassEffectCompatible(in: .capsule)
    //    .depthShadow(
    //      opacity: 0.3,
    //      radius: 20,
    //      distanceY: 10,
    //      depthIntensity: 0,
    //    )
    .padding()
    .font(.title2)

  }
}

extension ToolsView {

  @ViewBuilder
  private func MainTools(_ configuration: ToolConfiguration) -> some View {

    VStack(alignment: .leading, spacing: 0) {

      if !configuration.tools.isEmpty {
        ForEach(configuration.tools, id: \.id) { tool in
          ToolButtonView(
            toolHandler: store.toolHandler,
            tool: tool,
            toolbarWidth: toolbarWidth,
          )
          //          ToolButton(for: tool)
        }

      } else {
        Text("No Tools registered")
          .foregroundStyle(.tertiary)
      }
    }  // END vstack

  }

}
