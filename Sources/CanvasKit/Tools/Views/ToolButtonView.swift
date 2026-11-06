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

      //              .opacity(isToolActive(tool) ? 1 : 0.5)
      //        .frame(width: toolbarWidth, height: toolbarWidth)
      //        .tint(.blue)

      //        .padding(.horizontal, 6)

      //        .border(Color.green.opacity(0.05))
      //                    .background(.white.opacity(isToolActive(tool) ? 0.06 : 0))
    }
    .environment(\.isEmphasised, isActive)
    
    //    .foregroundStyle(.blue)
    .help(tool.name)
    //    .buttonStyle(.glassProminent)
    //    .pointerStyleCompatible(.default)

  }
}

extension ToolButtonView {
  var isActive: Bool {
    //  func isToolActive(_ tool: any CanvasTool) -> Bool {
    toolHandler.isActive(id: tool.id)
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
        return isActive ? .primary : .secondary
    }
  }
}
