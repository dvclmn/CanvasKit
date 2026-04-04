//
//  CanvasExtensions.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//

import SwiftUI

extension View where Self: CanvasAddressable {
  public func zoomRange(_ range: ClosedRange<Double>) -> some View {
    self.environment(\.zoomRange, range)
  }
}
