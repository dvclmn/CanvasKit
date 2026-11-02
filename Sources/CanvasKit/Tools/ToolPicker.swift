//
//  ToolPicker.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/11/2026.
//

import SwiftUI

public struct ToolPicker: View {
  @Binding var selection: ToolSelection
  let configuration: ToolConfiguration

  public init(
    selection: Binding<ToolSelection>,
    configuration: ToolConfiguration,
  ) {
    self._selection = selection
    self.configuration = configuration
  }

  public var body: some View {

    Picker("Tools", selection: $selection) {
      ForEach(configuration.tools, id: \.id) { tool in
        Label(tool.name, systemImage: tool.icon)
          .tag(ToolSelection(id: tool.id))
          .keyboardShortcut(configuration.shortcut(for: tool.id))
      }
    }

  }
}
