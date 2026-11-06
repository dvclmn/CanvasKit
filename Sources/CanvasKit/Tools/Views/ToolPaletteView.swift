//
//  CanvasToolPalette.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/4/2026.
//

import SwiftUI
private import ViewTools

struct CanvasToolPalette: View {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.toolPaletteConfiguration) private var configuration

  var body: some View {

    VStack(spacing: 4) {

      if let configuration = store.toolHandler.configuration {
        MainTools(configuration)
      }

      Divider()

      Button {
        store.currentTransform.scale = 1.0
        store.currentTransform.translation = .zero

      } label: {
        Label("Re-centre artwork", systemImage: "viewfinder")
          .opacity(0.7)
      }

    }  // END main vstack
    .buttonStyle(.toolButton(width: effectiveWidth))
    .labelStyle(.iconOnly)
    .padding(.vertical, configuration.paddingH)
    .padding(.horizontal, configuration.paddingH)
    .frame(width: configuration.width)
    .glassEffectCompatible(configuration.glass, in: .capsule)
    //    .depthShadow(
    //      opacity: 0.3,
    //      radius: 20,
    //      distanceY: 10,
    //      depthIntensity: 0,
    //    )

    // Padding seperating Tools from edge of the app window
    .padding()
    .font(.title2)
  }
}

extension CanvasToolPalette {

  private var effectiveWidth: CGFloat {
    configuration.width - (configuration.paddingH * 2)
  }

  @ViewBuilder
  private func MainTools(_ configuration: ToolConfiguration) -> some View {
    VStack(spacing: 0) {
      ForEach(configuration.tools, id: \.id) { tool in
        ToolButtonView(
          toolHandler: store.toolHandler,
          tool: tool,
          toolbarWidth: effectiveWidth,
        )
      }
    }  // END vstack
  }
}
