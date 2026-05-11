//
//  PanRepresentable.swift
//  Paperbark
//
//  Created by Dave Coleman on 24/6/2025.
//

#if canImport(AppKit)
import SwiftUI

struct SwipeGestureView: NSViewRepresentable {
  let onSwipeGesture: SwipeOutput

  init(_ onSwipeGesture: @escaping SwipeOutput) {
    self.onSwipeGesture = onSwipeGesture
  }

  func makeNSView(context: Context) -> SwipeTrackingNSView {
    let view = SwipeTrackingNSView()
    view.onSwipeGesture = { event in
      self.onSwipeGesture(event)
    }
    return view
  }

  func updateNSView(_ nsView: SwipeTrackingNSView, context: Context) {}
}
#endif
