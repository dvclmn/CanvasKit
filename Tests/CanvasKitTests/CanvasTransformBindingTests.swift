//
//  CanvasTransformBindingTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/8/2026.
//

import AppKit
import SwiftUI
import Testing

@testable import CanvasKit

struct CanvasTransformBindingTests {

  @Test @MainActor
  func externalTransformSurvivesCanvasRecreationAndRemainsBidirectional() async throws {
    let initialTransform = TransformState(
      translation: .init(width: 42, height: -18),
      scale: 2.5,
      rotation: .degrees(17),
    )
    let model = TransformLifecycleModel(transform: initialTransform)
    let recorder = TransformHandlerRecorder()
    let hostingView = NSHostingView(
      rootView: TransformLifecycleHost(model: model, recorder: recorder)
    )
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 320, height: 240),
      styleMask: [.borderless],
      backing: .buffered,
      defer: false,
    )
    window.isReleasedWhenClosed = false
    window.contentView = hostingView
    window.orderFrontRegardless()
    defer {
      window.orderOut(nil)
      window.contentView = nil
    }

    #expect(await waitUntil { recorder.handlers.count == 1 })
    let firstHandler = try #require(recorder.handlers.first)
    #expect(model.transform == initialTransform)
    #expect(firstHandler.currentTransform == initialTransform)

    let localUpdate = TransformState(
      translation: .init(width: -12, height: 28),
      scale: 1.75,
      rotation: .degrees(-9),
    )
    firstHandler.currentTransform = localUpdate
    #expect(await waitUntil { model.transform == localUpdate })

    let externalUpdate = TransformState(
      translation: .init(width: 64, height: 8),
      scale: 3,
      rotation: .degrees(31),
    )
    model.transform = externalUpdate
    #expect(await waitUntil { firstHandler.currentTransform == externalUpdate })

    model.showsCanvas = false
    #expect(await waitUntil { recorder.disappearedHandlers.count == 1 })
    model.showsCanvas = true

    #expect(await waitUntil { recorder.handlers.count == 2 })
    let reconstructedHandler = try #require(recorder.handlers.last)
    #expect(firstHandler !== reconstructedHandler)
    #expect(model.transform == externalUpdate)
    #expect(reconstructedHandler.currentTransform == externalUpdate)

    let reconstructedLocalUpdate = TransformState(
      translation: .init(width: 5, height: -40),
      scale: 0.8,
      rotation: .degrees(4),
    )
    reconstructedHandler.currentTransform = reconstructedLocalUpdate
    #expect(await waitUntil { model.transform == reconstructedLocalUpdate })
  }
}

@MainActor
@Observable
private final class TransformLifecycleModel {
  var transform: TransformState
  var showsCanvas = true

  init(transform: TransformState) {
    self.transform = transform
  }
}

@MainActor
private final class TransformHandlerRecorder {
  private(set) var handlers: [CanvasHandler] = []
  private(set) var disappearedHandlers: [CanvasHandler] = []

  func recordAppearance(of handler: CanvasHandler) {
    guard !handlers.contains(where: { $0 === handler }) else { return }
    handlers.append(handler)
  }

  func recordDisappearance(of handler: CanvasHandler) {
    guard !disappearedHandlers.contains(where: { $0 === handler }) else { return }
    disappearedHandlers.append(handler)
  }
}

private struct TransformLifecycleHost: View {
  @Bindable var model: TransformLifecycleModel
  let recorder: TransformHandlerRecorder

  var body: some View {
    Group {
      if model.showsCanvas {
        CanvasView(
          size: CGSize(width: 200, height: 120),
          transform: $model.transform,
        ) {
          TransformHandlerProbe(recorder: recorder)
        }
      }
    }
  }
}

private struct TransformHandlerProbe: View {
  @Environment(CanvasHandler.self) private var handler
  let recorder: TransformHandlerRecorder

  var body: some View {
    Color.clear
      .onAppear {
        recorder.recordAppearance(of: handler)
      }
      .onDisappear {
        recorder.recordDisappearance(of: handler)
      }
  }
}

@MainActor
private func waitUntil(
  timeout: Duration = .seconds(1),
  _ condition: @MainActor () -> Bool,
) async -> Bool {
  let clock = ContinuousClock()
  let deadline = clock.now.advanced(by: timeout)

  while clock.now < deadline {
    if condition() { return true }
    try? await clock.sleep(for: .milliseconds(10))
  }

  return condition()
}
