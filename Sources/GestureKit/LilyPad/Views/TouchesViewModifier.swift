//
//  TouchesView.swift
//  LilyPad
//
//  Created by Dave Coleman on 7/5/2025.
//

import BasePrimitives
import SwiftUI

public struct TrackpadTouchesModifier: ViewModifier {
  @State private var localTouches: Set<TouchPoint> = []

  let isEnabled: Bool
  let mapStrategy: ContentSizeMode
  let shouldShowIndicators: Bool
  let didUpdateTouches: TouchesUpdate
  let didUpdatePressure: PressureUpdate

  public func body(content: Content) -> some View {
    GeometryReader { proxy in
      content
      if isEnabled && shouldShowIndicators {
        TouchIndicatorsView(
          mappedTouches: localTouches.toArray,
          mappingStrategy: mapStrategy,
          containerSize: proxy.size,
        )
      }
      if isEnabled {
        TrackpadTouchesView { touchOutput in
          didUpdateTouches(touchOutput)

          if shouldShowIndicators {
            self.localTouches = touchOutput
          }
        }
      }
    }  // END geo reader
  }
}
extension View {

  public func touches(
    isEnabled: Bool = true,
    mapStrategy: ContentSizeMode,
    showIndicators: Bool = true,
    didUpdateTouches: @escaping TouchesUpdate,
    didUpdatePressure: @escaping PressureUpdate = { _ in }
  ) -> some View {
    self.modifier(
      TrackpadTouchesModifier(
        isEnabled: isEnabled,
        mapStrategy: mapStrategy,
        shouldShowIndicators: showIndicators,
        didUpdateTouches: didUpdateTouches,
        didUpdatePressure: didUpdatePressure,
      )
    )
  }
}
