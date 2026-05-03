//
//  DebugOverlayModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/5/2026.
//

import SwiftUI
import CoreUtilities

struct DebugOverlayModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  
//  let isEnabled: Bool
  func body(content: Content) -> some View {
    content
      .debugText {
        Indented("Tools") {
          for tool in store.toolHandler.configuration.tools {
            Indented(tool.name) {
              Labeled("Input Capabilities", value: tool.inputCapabilities)
              //            if let context = store.interactionContext {
              //              Labeled("Resolution", value: tool.resolvePointerStyle(context: context))
              //            } else {
              //              "No context found"
              //            }
              
            }
          }
          
        }
      }
  }
}
