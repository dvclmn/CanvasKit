//
//  CanvasHoverModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 22/4/2026.
//

private import CoreTools
import SwiftUI

public struct CanvasHoverModifier: ViewModifier {
  @Environment(\.pointerHover) private var pointerHover

  let action: (CanvasHoverPhase) -> Void

  public func body(content: Content) -> some View {
    content
      .onChange(of: pointerHover) {
        action(CanvasHoverPhase(from: pointerHover))
      }
  }
}

/// A global canvas-hover observation independent of the effective tool.
public enum CanvasHoverPhase: Sendable, Equatable {
  /// The pointer's location within the CanvasView, in local CanvasSpace.
  case active(Point<CanvasSpace>)

  /// The pointer exited the CanvasView.
  case ended

  init(from point: Point<CanvasSpace>?) {
    if let point {
      self = .active(point)
    } else {
      self = .ended
    }
  }
}
