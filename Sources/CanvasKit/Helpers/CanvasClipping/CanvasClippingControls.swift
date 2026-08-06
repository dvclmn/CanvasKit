//
//  CanvasClippingControl.swift
//  CanvasKit
//
//  Created by Dave Coleman on 5/5/2026.
//

import SwiftUI

public struct CanvasClippingControls: View {
  
  @Binding private var clipping: CanvasClipping
  @State private var lastDimmingAmount: Double

  private static let defaultDimmingAmount = 0.5

  public init(_ clipping: Binding<CanvasClipping>) {
    self._clipping = clipping

    let dimming = clipping.wrappedValue.preferredDimmingAmount(
      fallback: Self.defaultDimmingAmount
    )
    self._lastDimmingAmount = State(initialValue: dimming)
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Picker("Clipping", selection: $clipping.meta) {
        ForEach(CanvasClippingMode.allCases) { mode in
          Text(mode.label).tag(mode)
        }
      }
      .pickerStyle(.segmented)

      if clipping.mode == .dimmed {
        Slider(
          value: dimmingAmount,
          in: 0...1,
        ) {
          Text("Dimming")
        } minimumValueLabel: {
          Text("0")
        } maximumValueLabel: {
          Text("1")
        }
      }
    }
    .onChange(of: clipping) { _, newValue in
      guard case .dimmed = newValue else { return }
      lastDimmingAmount = newValue.normalisedDimmingAmount
    }
  }
}

extension CanvasClippingControls {
//  fileprivate var mode: Binding<CanvasClippingMode> {
//    Binding {
//      clipping.mode
//    } set: { newMode in
//      switch newMode {
//        case .clipped:
//          clipping = .clipped
//
//        case .dimmed:
//          clipping = .dimmed(CGFloat(lastDimmingAmount))
//
//        case .none:
//          clipping = .none
//      }
//    }
//  }

  fileprivate var dimmingAmount: Binding<Double> {
    Binding {
      clipping.preferredDimmingAmount(fallback: lastDimmingAmount)
    } set: { newValue in
      let normalisedValue = CanvasClipping.normaliseDimmingAmount(newValue)
      lastDimmingAmount = normalisedValue
      clipping = .dimmed(CGFloat(normalisedValue))
    }
  }
}

extension CanvasClipping {
//  fileprivate var mode: CanvasClippingMode {
//    switch self {
//      case .clipped:
//        return .clipped
//      case .dimmed:
//        return .dimmed
//      case .none:
//        return .none
//    }
//  }

  fileprivate func preferredDimmingAmount(fallback: Double) -> Double {
    guard case .dimmed = self else { return fallback }
    return normalisedDimmingAmount
  }
}
