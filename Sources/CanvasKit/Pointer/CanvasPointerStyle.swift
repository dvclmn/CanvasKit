//
//  CanvasPointerStyle.swift
//  CanvasKit
//
//  Created by Dave Coleman on 1/6/2026.
//

import SwiftUI

/// A semantic pointer style resolved by CanvasKit's tool system.
///
/// CanvasKit keeps this type deliberately small and domain-specific. It
/// represents the pointer feedback CanvasKit's tools need, without exposing
/// SwiftUI's platform-gated `PointerStyle` API or ToolKit's compatibility
/// layer through CanvasKit's public surface.
public enum CanvasPointerStyle: Sendable, Equatable {

  /// The platform's default pointer.
  case `default`

  /// An open-hand pointer, used when content can be grabbed or panned.
  case grabIdle

  /// A closed-hand pointer, used while content is actively being dragged.
  case grabActive

  /// A zoom-in pointer.
  case zoomIn

  /// A zoom-out pointer.
  case zoomOut
}

extension CanvasPointerStyle: CustomStringConvertible {
  public var description: String { name }
}

extension CanvasPointerStyle {
  /// A short human-readable name suitable for debug UI.
  public var name: String {
    switch self {
      case .default: "Default"
      case .grabIdle: "Grab Idle"
      case .grabActive: "Grab Active"
      case .zoomIn: "Zoom In"
      case .zoomOut: "Zoom Out"
    }
  }
}

#if os(macOS)
extension CanvasPointerStyle {
  @available(macOS 15, *)
  var swiftUIPointerStyle: PointerStyle {
    switch self {
      case .default: .default
      case .grabIdle: .grabIdle
      case .grabActive: .grabActive
      case .zoomIn: .zoomIn
      case .zoomOut: .zoomOut
    }
  }
}
#endif

private struct CanvasPointerStyleModifier: ViewModifier {
  let style: CanvasPointerStyle?

  func body(content: Content) -> some View {
    #if os(macOS)
    if #available(macOS 15, *) {
      content.pointerStyle(style?.swiftUIPointerStyle)
    } else {
      content
    }
    #else
    content
    #endif
  }
}

extension View {
  /// Applies a CanvasKit pointer style where SwiftUI provides native support.
  ///
  /// On macOS 15 and later this maps ``CanvasPointerStyle`` to SwiftUI's native
  /// `PointerStyle`. On earlier OS versions the modifier is intentionally a
  /// no-op; apps that need custom cursor behaviour there can observe
  /// ``CanvasView``'s `pointerStyle` binding and bridge to their own AppKit
  /// cursor handling.
  public func canvasPointerStyle(_ style: CanvasPointerStyle?) -> some View {
    modifier(CanvasPointerStyleModifier(style: style))
  }
}
