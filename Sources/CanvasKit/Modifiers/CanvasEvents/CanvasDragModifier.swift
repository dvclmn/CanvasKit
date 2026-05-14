//
//  OnCanvasDragModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 23/3/2026.
//

import CoreUtilities

import InputPrimitives
import SwiftUI

public struct CanvasDragModifier: ViewModifier {
  @Environment(\.pointerDrag) private var pointerDrag
  @Environment(\.activeInteraction) private var activeInteraction
  //  @Environment(\.interactionPhase) private var interactionPhase

  let action: (CanvasDragEvent) -> Void
  public func body(content: Content) -> some View {
    content
      .onChange(of: pointerDrag) {
        if let pointerDrag {
          let event = CanvasDragEvent(
            rect: pointerDrag,
            phase: activeInteraction.phase,
          )
          action(event)
          //          action
        }
        //        guard let pointerDrag else {
        //          printMissing("pointerDrag", for: "CanvasDragModifier")
        //          return
        //        }
        //        guard activeInteraction.kind == .drag else {
        //          print("Expected `InteractionKind/drag`, got: \(activeInteraction.kind)")
        //          return
        //        }

      }
  }
}

public struct CanvasDragEvent {
  //public struct CanvasDragEvent<Space> {
  public let rect: Rect<CanvasSpace>
  public let phase: InteractionPhase
}
