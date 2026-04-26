//
//  OnCanvasDragModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 23/3/2026.
//

import CoreUtilities
import GeometryPrimitives
import InputPrimitives
import SwiftUI

public struct CanvasDragModifier: ViewModifier {
  @Environment(\.pointerDrag) private var pointerDrag
  @Environment(\.interactionPhase) private var interactionPhase

  let action: (CanvasDragEvent<CanvasSpace>) -> Void
  public func body(content: Content) -> some View {
    content
      .onChange(of: pointerDrag) {
        guard let pointerDrag else {
          printMissing("pointerDrag", for: "CanvasDragModifier")
          return
        }

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
