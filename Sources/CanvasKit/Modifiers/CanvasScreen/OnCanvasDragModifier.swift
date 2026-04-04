//
//  OnCanvasDragModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 23/3/2026.
//

import InteractionKit
import SwiftUI

/// Observes pointer drag events and delivers the rect ~~in the requested coordinate space.~~
/// Update: Decided for now to keep this as `CanvasSpace` only
struct OnCanvasDragModifier: ViewModifier {
  //struct OnCanvasDragModifier<Space: CanvasCoordinateSpace>: ViewModifier {
  //  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.pointerDrag) private var pointerDrag
  @Environment(\.interactionPhase) private var interactionPhase

  let action: (CanvasDragEvent<CanvasSpace>) -> Void
  //  let action: (CanvasDragEvent<Space>) -> Void

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
