//
//  CanvasHoverModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 22/4/2026.
//

import CoreUtilities
import GeometryPrimitives
import SwiftUI

public struct CanvasHoverModifier: ViewModifier {
  @Environment(\.pointerHover) private var pointerHover
//  @Environment(\.activeInteraction) private var activeInteraction
  //  @Environment(\.interactionPhase) private var interactionPhase

  let action: (CanvasHoverPhase) -> Void

  public func body(content: Content) -> some View {
    content
      .onChange(of: pointerHover) {
        //        guard let pointerHover else {
        //          printMissing("pointerHover", for: "CanvasHoverModifier")
        //          return
        //        }
        action(CanvasHoverPhase(from: pointerHover))
      }
  }
}

public enum CanvasHoverPhase {
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
