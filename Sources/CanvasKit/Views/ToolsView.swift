//
//  ToolsView.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/4/2026.
//

import BasePrimitives
import SwiftUI

struct ToolsView: View {
  @Environment(\.modifierKeys) private var modifierKeys
  @State private var isSelectFontActive: Bool = true
  @State private var localCanvasZoom: CGFloat = 1.0

  private let toolbarWidth: Double = 36

  var body: some View {

    VStack(spacing: Styles.sizeSmall) {

      VStack(alignment: .leading, spacing: 0) {

        if !store.toolConfiguration.availableTools.isEmpty {
          //        if !store.toolHandler.availableTools.isEmpty {
          ForEach(store.toolConfiguration.availableTools, id: \.kind) { tool in
            //          ForEach(store.toolHandler.availableTools, id: \.kind) { tool in
            ToolButton(for: tool)
          }

        } else {
          StateView("No Tools registered")
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
    .labelStyle(.base(display: .iconOnly))
    //    .setLabelDisplay(.iconOnly)
    //    .setSymbolVariants(.fill)

    .quickRoundedBackground(glass: .regular(tint: .black.opacity(0.5)))

    .depthShadow(
      opacity: 0.3,
      radius: 20,
      distanceY: 10,
      depthIntensity: 0,
    )

    .environment(\.layoutSpacing, 0)

    .padding(Constants.basePadding)
    .font(.title3)
    //    .animation(Styles.animationSpringQuickNSubtle, value: paddingLeading)

    //    .offset(y: documentCount.multipleOpen ? Styles.titleBarHeight : 0)
    //    .animation(Styles.animationSpringSubtle, value: documentCount.multipleOpen)
  }
}

extension ToolsView {

  @ViewBuilder
  private func ToolButton(for tool: any CanvasTool) -> some View {

    Button {
      store.toolConfiguration.select(tool.kind)
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
            RoundedRectangle(cornerRadius: Styles.sizeTiny)
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
    guard let kind = store.toolConfiguration.selectedTool?.kind else { return false }
    return kind == tool.kind
    //    store.toolHandler.effectiveTool(modifiers: modifierKeys) == tool
  }
}

#if DEBUG
#Preview(traits: .size(.normal)) {
  @Previewable @State var store = AppHandler()
  ToolsView()
    .environment(store)
    .frame(maxWidth: 400, maxHeight: .infinity, alignment: .topLeading)
    .background {
      Image("flower")
        .resizable()
        .scaledToFill()
        .scaleEffect(3.0)
    }
}
#endif
