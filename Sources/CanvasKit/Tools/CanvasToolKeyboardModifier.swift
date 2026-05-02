//
//  CanvasToolKeyboardModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 15/4/2026.
//

import SwiftUI

struct CanvasToolKeyboardModifier: ViewModifier {

  /// Will need to get modifier keys in here from somewhere

  @Binding var toolHandler: ToolHandler
  @FocusState private var isFocused: Bool

  func body(content: Content) -> some View {
    content
      .focusable(true)
      .focused($isFocused)
      .focusEffectDisabled()
      .onAppear {
        isFocused = true
      }
      .onKeyPress(
        keys: toolHandler.keysToWatch,
        phases: .all,
      ) { result in

        switch result.phase {
          case .up:
            toolHandler.handleKeyUp(result.key)

          case .down:
            toolHandler.handleKeyDown(result.key)
          default: break
        }

        return .handled
      }
    //      .onEnvironmentChange(\.modifierKeys) { <#Equatable#> in
    //        <#code#>
    //      }
  }
}

//extension View {
//  public func example() -> some View {
//    self.modifier(ExampleModifier())
//  }
//}

//
//#if canImport(AppKit)
//import AppKit
//#endif
//
//struct CanvasToolKeyboardModifier: ViewModifier {
//  @Binding var toolHandler: ToolHandler
//  let isEnabled: Bool
//
//  #if canImport(AppKit)
//  @State private var keyDownMonitor: Any?
//  @State private var keyUpMonitor: Any?
//  #endif
//
//  func body(content: Content) -> some View {
//    #if canImport(AppKit)
//    content
//      .onAppear { syncMonitors() }
//      .onDisappear { removeMonitors() }
//      .onChange(of: isEnabled, initial: true) { _, _ in
//        syncMonitors()
//      }
//    #else
//    content
//    #endif
//  }
//}
//
//#if canImport(AppKit)
//extension CanvasToolKeyboardModifier {
//
//  private func syncMonitors() {
//    if isEnabled {
//      installMonitors()
//    } else {
//      removeMonitors()
//    }
//  }
//
//  private func installMonitors() {
//    guard keyDownMonitor == nil, keyUpMonitor == nil else { return }
//
//    keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
//      self.handleKeyDown(event)
//    }
//
//    keyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyUp]) { event in
//      self.handleKeyUp(event)
//    }
//  }
//
//  private func removeMonitors() {
//    if let keyDownMonitor {
//      NSEvent.removeMonitor(keyDownMonitor)
//      self.keyDownMonitor = nil
//    }
//    if let keyUpMonitor {
//      NSEvent.removeMonitor(keyUpMonitor)
//      self.keyUpMonitor = nil
//    }
//  }
//
//  private func handleKeyDown(_ event: NSEvent) -> NSEvent {
//    guard isEnabled, !event.isARepeat, let key = keyEquivalent(for: event) else { return event }
//
//    var handler = toolHandler
//    handler.updateModifiers(Modifiers(from: event))
//    handler.handleKeyDown(key)
//    toolHandler = handler
//    return event
//  }
//
//  private func handleKeyUp(_ event: NSEvent) -> NSEvent {
//    guard isEnabled, let key = keyEquivalent(for: event) else { return event }
//
//    var handler = toolHandler
//    handler.updateModifiers(Modifiers(from: event))
//    handler.handleKeyUp(key)
//    toolHandler = handler
//    return event
//  }
//
//  private func keyEquivalent(for event: NSEvent) -> KeyEquivalent? {
//    guard let character = event.charactersIgnoringModifiers?.first else { return nil }
//    return KeyEquivalent(character)
//  }
//}
//#endif
