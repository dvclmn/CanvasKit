//
//  ToolsView.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/4/2026.
//

import CoreUtilities
import SwiftUI

struct ToolsView: View {
  @Environment(CanvasHandler.self) private var store

  private let toolbarWidth: Double = 36

  //  @Binding var transform: TransformState

  /// Runtime tool state, not just the durable configuration.
  ///
  /// The toolbar highlights ``ToolHandler/effectiveToolKind`` so transient
  /// overrides such as Space-held Pan are reflected immediately.
  //  let toolHandler: ToolHandler

  var body: some View {

    VStack(spacing: 6) {

      MainTools()

      Divider()
        .frame(width: toolbarWidth * 0.7)

      VStack(alignment: .leading) {
        Group {
          Button {
            store.currentTransform?.scale = 1.0
            store.currentTransform?.translation = .zero

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

    .padding(6)

    .glassEffectCompatible(in: .capsule)
    //    .glassEffectCompatible(in: .rect(cornerRadius: 6))
    //    .background {
    //      RoundedRectangle(cornerRadius: 6)
    //        .fill(Color.white.opacity(0.08))
    //        .fill(.regularMaterial)
    //
    //    }
    //    .shadow(
    //      radius: 100,
    //      x: 0,
    //      y: 10,
    //    )
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
  private func MainTools() -> some View {

    VStack(alignment: .leading, spacing: 0) {

      if !store.toolHandler.configuration.tools.isEmpty {
        ForEach(store.toolHandler.configuration.tools, id: \.kind) { tool in
          ToolButton(for: tool)
        }

      } else {
        Text("No Tools registered")
          .foregroundStyle(.tertiary)
      }
    }  // END vstack

  }

  @ViewBuilder
  private func ToolButton(for tool: any CanvasTool) -> some View {

    Button {
      store.toolHandler.setCommittedTool(kind: tool.kind)
    } label: {
      Label(tool.name, systemImage: tool.icon)
        .foregroundStyle(isToolActive(tool) ? .primary : .secondary)
        .symbolVariant(.fill)
        .symbolRenderingMode(.hierarchical)
        //              .opacity(isToolActive(tool) ? 1 : 0.5)
        .frame(width: toolbarWidth, height: toolbarWidth)
        .contentShape(Rectangle())
        .tint(.blue)
      //        .background {
      //          if isToolActive(tool) {
      //            RoundedRectangle(cornerRadius: 5)
      //              .fill(.quaternary)
      //          }
      //        }
      //              .background(.white.opacity(isToolActive(tool) ? 0.06 : 0))
    }
    .foregroundStyle(.blue)
    .help(tool.name)
    //    .buttonStyle(.glassProminent)

  }
  func isToolActive(_ tool: any CanvasTool) -> Bool {
    store.toolHandler.effectiveToolKind == tool.kind
  }
}
