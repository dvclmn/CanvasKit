//
//  CanvasClippingControl.swift
//  CanvasKit
//
//  Created by Dave Coleman on 5/5/2026.
//

import SwiftUI

public struct CanvasClippingControls: View {

  @State private var lastDimmingAmount: Double
  private static let defaultDimmingAmount = 0.5

  @Binding private var clipping: CanvasClipping
  private let spacing: CGFloat

  public init(
    _ clipping: Binding<CanvasClipping>,
    spacing: CGFloat = 10,
  ) {
    self._clipping = clipping
    self.spacing = spacing

    let dimming = clipping.wrappedValue.preferredDimmingAmount(
      fallback: Self.defaultDimmingAmount
    )
    self._lastDimmingAmount = State(initialValue: dimming)
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: spacing) {
      Picker("Clipping", selection: meta) {
        ForEach(CanvasClipping.Meta.allCases) { mode in
          Text(mode.displayString).tag(mode)
        }
      }
      .pickerStyle(.segmented)

      if clipping.meta == .dimmed {
        Slider(
          value: dimmingAmount,
          in: 0...1,
        ) {
          Text("Dimming")
        }
        //        minimumValueLabel: {
        //          Text("0")
        //        } maximumValueLabel: {
        //          Text("1")
        //        }
      }
    }
    .onChange(of: clipping) { _, newValue in
      guard case .dimmed = newValue else { return }
      lastDimmingAmount = newValue.normalisedDimmingAmount
    }
  }
}

extension CanvasClippingControls {
  fileprivate var meta: Binding<CanvasClipping.Meta> {
    Binding {
      clipping.meta

    } set: { newMode in
      switch newMode {
        case .clipped: self.clipping = .clipped
        case .dimmed: self.clipping = .dimmed(CGFloat(lastDimmingAmount))
        case .none: self.clipping = .none
      }
    }
  }

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
  fileprivate func preferredDimmingAmount(fallback: Double) -> Double {
    guard case .dimmed = self else { return fallback }
    return normalisedDimmingAmount
  }
}
