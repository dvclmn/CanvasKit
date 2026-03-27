//
//  PanRepresentable.swift
//  Paperbark
//
//  Created by Dave Coleman on 24/6/2025.
//

#if canImport(AppKit)
import SwiftUI

struct SwipeGestureView: NSViewRepresentable {
  let onSwipeGesture: SwipeOutputInternal
  
  init(_ onSwipeGesture: @escaping SwipeOutputInternal) {
    self.onSwipeGesture = onSwipeGesture
  }

  func makeNSView(context: Context) -> SwipeTrackingNSView {
    let view = SwipeTrackingNSView()
    view.onSwipeGesture = { event, modifiers in
      self.onSwipeGesture(event, modifiers)
    }
    return view
  }

  func updateNSView(_ nsView: SwipeTrackingNSView, context: Context) {}
}
#endif
