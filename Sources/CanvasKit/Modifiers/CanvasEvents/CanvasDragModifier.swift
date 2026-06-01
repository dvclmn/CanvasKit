//
//  OnCanvasDragModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 23/3/2026.
//

private import CoreTools
import SwiftUI
private import ViewTools

public struct CanvasDragModifier: ViewModifier {
  @Environment(\.pointerDrag) private var pointerDrag
  @Environment(\.activeInteraction) private var activeInteraction

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
        }
      }
  }
}

public struct CanvasDragEvent {
  //public struct CanvasDragEvent<Space> {
  public let rect: Rect<CanvasSpace>
  public let phase: InteractionPhase
}
