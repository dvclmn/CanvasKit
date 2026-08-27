//
//  ToolsView.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/4/2026.
//

import SwiftUI
private import ViewTools

struct ToolsView: View {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.toolPaletteConfiguration) private var configuration
//  let toolbarWidth: Double = 36
//  private let toolbarPadding: Double = 6
  
  var body: some View {

    VStack(spacing: 6) {

      if let configuration = store.toolHandler.configuration {
        MainTools(configuration)
      }

      Divider()
        .frame(width: configuration.width * 0.7)

      Button {
        store.currentTransform.scale = 1.0
        store.currentTransform.translation = .zero

      } label: {
        Label("Re-centre artwork", systemImage: "viewfinder")
          .opacity(0.7)
      }
//      .buttonStyle(.toolButton(width: effectiveWidth))

    }  // END main vstack
//    .buttonStyle(.plain)
//    .tint(.gray)
    .buttonStyle(.toolButton(width: configuration.width))
    .labelStyle(.iconOnly)
    .padding(.vertical, Styles.sizeSmall)
    .padding(.horizontal, Styles.sizeSmall)
    .glassEffectCompatible(in: .capsule)
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

extension ToolsView {

  private var effectiveWidth: CGFloat {
    configuration.width - (configuration.paddingH * 2)
  }

  @ViewBuilder
  private func MainTools(_ configuration: ToolConfiguration) -> some View {

    VStack(alignment: .leading, spacing: 0) {

      if !configuration.tools.isEmpty {
        ForEach(configuration.tools, id: \.id) { tool in
          ToolButtonView(
            toolHandler: store.toolHandler,
            tool: tool,
            toolbarWidth: effectiveWidth,
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
