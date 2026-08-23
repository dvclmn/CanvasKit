//
//  ToolButtonView.swift
//  CanvasKit
//
//  Created by Dave Coleman on 23/8/2026.
//

import SwiftUI

struct ToolButtonView: View {
  // @Environment(AppHandler.self) private var store

  let toolHandler: ToolHandler
  let tool: any CanvasTool
  let toolbarWidth: CGFloat

  var body: some View {

    Button {
      toolHandler.setCommittedTool(id: tool.id)
    } label: {
      Label(tool.name, systemImage: tool.icon)
        .foregroundStyle(toolForegroundColour(for: tool))
        .symbolVariant(.fill)
        .symbolRenderingMode(.hierarchical)
        //              .opacity(isToolActive(tool) ? 1 : 0.5)
        .frame(width: toolbarWidth, height: toolbarWidth)
        .contentShape(Rectangle())
        //        .tint(.blue)
        .background {
          if isToolActive(tool) {
            RoundedRectangle(cornerRadius: 5)
              .fill(.quaternary)
          }
        }
      //                    .background(.white.opacity(isToolActive(tool) ? 0.06 : 0))
    }

    .foregroundStyle(.blue)
    .help(tool.name)
    //    .buttonStyle(.glassProminent)

  }
}

extension ToolButtonView {
  func isToolActive(_ tool: any CanvasTool) -> Bool {
    toolHandler.effectiveToolID == tool.id
  }

  func toolForegroundColour(for tool: any CanvasTool) -> Color {
    switch toolHandler.activationStatus(for: tool.id) {
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
