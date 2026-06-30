//
//  PanRepresentable.swift
//  Paperbark
//
//  Created by Dave Coleman on 24/6/2025.
//

import SwiftUI

typealias SwipeHandler = (SwipeEvent) -> Bool

struct SwipeGestureView: NSViewRepresentable {
  let onSwipeGesture: SwipeHandler

  init(_ onSwipeGesture: @escaping SwipeHandler) {
    self.onSwipeGesture = onSwipeGesture
  }

  func makeNSView(context: Context) -> SwipeTrackingNSView {
    let view = SwipeTrackingNSView()
    view.onSwipeGesture = onSwipeGesture
    return view
  }

  func updateNSView(_ nsView: SwipeTrackingNSView, context: Context) {
    nsView.onSwipeGesture = onSwipeGesture
  }
}
