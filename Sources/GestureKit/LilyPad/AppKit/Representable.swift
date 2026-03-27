//
//  Representable.swift
//  LilyPad
//
//  Created by Dave Coleman on 3/5/2025.
//

#if canImport(AppKit)
import SwiftUI
import BasePrimitives

public typealias TouchesUpdate = (Set<TouchPoint>) -> Void
public typealias PressureUpdate = (CGFloat) -> Void

struct TrackpadTouchesView: NSViewRepresentable {
  var didUpdateTouches: TouchesUpdate

  public func makeNSView(context: Context) -> TrackpadTouchesNSView {
    let view = TrackpadTouchesNSView(didUpdateTouches)
    return view
  }

  public func updateNSView(_ nsView: TrackpadTouchesNSView, context: Context) {}
}
#endif
