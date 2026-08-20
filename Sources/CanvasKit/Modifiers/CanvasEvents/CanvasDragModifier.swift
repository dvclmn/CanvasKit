//
//  OnCanvasDragModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 23/3/2026.
//

import SwiftUI

public struct CanvasDragModifier: ViewModifier {
  @Environment(\.canvasDragEvent) private var event

  let action: (CanvasDragEvent) -> Void
  public func body(content: Content) -> some View {
    content
      .onChange(of: event) {
        if let event {
          action(event)
        }
      }
  }
}
