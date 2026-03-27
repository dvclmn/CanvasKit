//
//  TouchesNSView.swift
//  LilyPad
//
//  Created by Dave Coleman on 3/5/2025.
//

import AppKit
import BasePrimitives

/// The underlying AppKit NSView that captures raw trackpad touches
public class TrackpadTouchesNSView: NSView {
  var onTouchesChanged: TouchesUpdate

  private let touchManager = TrackpadTouchManager()

  public init(_ onTouchesChanged: @escaping TouchesUpdate) {
    self.onTouchesChanged = onTouchesChanged
    super.init(frame: .zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    allowedTouchTypes = [.indirect]
    wantsRestingTouches = true
  }

  private func processTouches(with event: NSEvent) {
    let nsTouches = event.allTouches()
    let processedTouches = touchManager.processCapturedTouches(
      nsTouches,
      timestamp: event.timestamp,
      in: .view(frame.size)
    )
    onTouchesChanged(processedTouches)
  }

  public override func touchesBegan(with event: NSEvent) {
    processTouches(with: event)
  }
  public override func touchesMoved(with event: NSEvent) {
    processTouches(with: event)
  }
  public override func touchesEnded(with event: NSEvent) {
    processTouches(with: event)
  }
  public override func touchesCancelled(with event: NSEvent) {
    processTouches(with: event)
  }
}
