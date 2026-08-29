//
//  CanvasTapModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 20/3/2026.
//

private import CoreTools
import SwiftUI

public struct CanvasTapModifier: ViewModifier {
  @Environment(\.pointerTapDelivery) private var delivery

  let action: (Point<CanvasSpace>) -> Void

  public func body(content: Content) -> some View {
    content
      // Observe physical delivery identity, not mapped location. The location
      // can change when an old viewport-space tap is reprojected after pan/zoom.
      .onChange(of: delivery?.deliveryID) {
        if let delivery {
          action(delivery.value)
        }
      }
  }
}
