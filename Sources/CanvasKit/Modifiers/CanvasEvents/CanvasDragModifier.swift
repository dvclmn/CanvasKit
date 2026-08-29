//
//  OnCanvasDragModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 23/3/2026.
//

import SwiftUI

public struct CanvasDragModifier: ViewModifier {
  @Environment(\.canvasDragDelivery) private var delivery

  let action: (CanvasDragEvent) -> Void
  public func body(content: Content) -> some View {
    content
      // A retained marquee can map to different CanvasSpace coordinates after
      // pan/zoom. Only a new physical lifecycle update is a new callback event.
      .onChange(of: delivery?.deliveryID) {
        if let delivery {
          action(delivery.value)
        }
      }
  }
}
