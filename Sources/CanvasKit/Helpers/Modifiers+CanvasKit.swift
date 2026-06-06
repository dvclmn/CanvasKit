//
//  Modifiers+CanvasKit.swift
//  CanvasKit
//
//  Created by Dave Coleman on 3/6/2026.
//

import SwiftUI
private import ViewTools

extension Modifiers {
  var canvasEventModifiers: EventModifiers {
    var result: EventModifiers = []

    if contains(.shift) { result.insert(.shift) }
    if contains(.option) { result.insert(.option) }
    if contains(.command) { result.insert(.command) }
    if contains(.control) { result.insert(.control) }
    if contains(.capsLock) { result.insert(.capsLock) }
    if contains(.numericPad) { result.insert(.numericPad) }

    return result
  }
}
