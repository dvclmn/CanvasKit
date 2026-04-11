//
//  OnCanvasDragModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 23/3/2026.
//

import InteractionKit
import SwiftUI

struct CanvasDragModifier: ViewModifier {
  @Environment(\.pointerDrag) private var pointerDrag
  @Environment(\.interactionPhase) private var interactionPhase

  let action: (CanvasDragEvent<CanvasSpace>) -> Void
  func body(content: Content) -> some View {
    content
      .onChange(of: pointerDrag) {
        guard let pointerDrag else { return }

        let event = CanvasDragEvent<CanvasSpace>(
          rect: pointerDrag,
          phase: interactionPhase,
        )
        action(event)
      }
  }
}

public struct CanvasDragEvent<Space> {
  public let rect: Rect<Space>
  public let phase: InteractionPhase
}
