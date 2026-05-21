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
    .padding(6)
    .glassEffectCompatible(in: .capsule)
    .padding()
    .font(.title2)
  }
}

extension ToolsView {

  @ViewBuilder
  private func MainTools(_ configuration: ToolConfiguration) -> some View {

    VStack(alignment: .leading, spacing: 0) {

      if !configuration.tools.isEmpty {
        ForEach(configuration.tools, id: \.kind) { tool in
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
        .foregroundStyle(toolForegroundColour(for: tool))
        .symbolVariant(.fill)
        .symbolRenderingMode(.hierarchical)
        //              .opacity(isToolActive(tool) ? 1 : 0.5)
        .frame(width: toolbarWidth, height: toolbarWidth)
        .contentShape(Rectangle())
      //        .tint(.blue)
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

  func toolForegroundColour(for tool: any CanvasTool) -> Color {
    switch store.toolHandler.activationStatus(for: tool.kind) {
      case .nonCommittingHold:
        return .blue

      case .heldPendingCommitOrRelease:
        return .orange

      case .springLoaded:
        return .green

      case nil:
        return isToolActive(tool) ? .primary : .secondary
    }
  }
}
