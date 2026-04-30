//
//  ToolsView.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/4/2026.
//

import CoreUtilities
import SwiftUI

struct ToolsView: View {
  @Environment(\.modifierKeys) private var modifierKeys
  @State private var isSelectFontActive: Bool = true
  @State private var localCanvasZoom: CGFloat = 1.0

  private let toolbarWidth: Double = 36

  @Binding var toolConfiguration: ToolConfiguration

  var body: some View {

    VStack(spacing: 6) {

      VStack(alignment: .leading, spacing: 0) {

        if !toolConfiguration.tools.isEmpty {
          ForEach(toolConfiguration.tools, id: \.kind) { tool in
            ToolButton(for: tool)
          }

        } else {
          Text("No Tools registered")
            .foregroundStyle(.tertiary)
        }
      }  // END vstack

      Divider()
        .frame(width: toolbarWidth * 0.7)

      VStack(alignment: .leading) {
        Group {
          Button {
            print("Need to bring this back")
            //            store.canvasHandler.updateGesture(.zoom(.fit))
            //            store.canvasHandler.zoomHandler.zoomToFit()

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
    .background {
      RoundedRectangle(cornerRadius: 6)
        .fill(Color.white.opacity(0.08))
        .fill(.regularMaterial)

    }
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
  private func ToolButton(for tool: any CanvasTool) -> some View {

    Button {
      toolConfiguration.select(tool.kind)
      //      store.toolHandler.setBaseTool(tool)
    } label: {
      Label(tool.name, systemImage: tool.icon)
        .foregroundStyle(isToolActive(tool) ? .primary : .secondary)
        .symbolVariant(.fill)
        .symbolRenderingMode(.hierarchical)
        //              .opacity(isToolActive(tool) ? 1 : 0.5)
        .frame(width: toolbarWidth, height: toolbarWidth)
        .contentShape(Rectangle())
        .background {
          if isToolActive(tool) {
            RoundedRectangle(cornerRadius: 5)
              .fill(.quaternary)
          }
        }
      //              .background(.white.opacity(isToolActive(tool) ? 0.06 : 0))
    }
    .help(tool.name)
  }
  func isToolActive(_ tool: any CanvasTool) -> Bool {
    //  func isToolActive(_ tool: Tool) -> Bool {
    //    store.toolHandler.toolKind == tool.kind
    guard let kind = toolConfiguration.selectedTool?.kind else { return false }
    return kind == tool.kind
    //    store.toolHandler.effectiveTool(modifiers: modifierKeys) == tool
  }
}
