//
//  Pinch+ViewExts.swift
//  CanvasKit
//
//  Created by Dave Coleman on 17/3/2026.
//

private import CoreTools
import SwiftUI
private import ViewTools

extension View {

  /// Adds a pinch gesture whose zoom is externally owned by a binding.
  ///
  /// The binding supplies the initial zoom and remains authoritative while no
  /// pinch is active. During an active pinch, the gesture owns its working
  /// value and commits each resolved proposal back to the binding.
  ///
  /// - Parameters:
  ///   - zoom: The external source of truth before and after each pinch update.
  ///   - isEnabled: Whether the pinch gesture can begin.
  ///   - resolve: Resolves each gesture proposal. Return
  ///     ``ZoomProposal/proposedZoom`` to accept it unchanged.
  public func onPinchGesture(
    zoom: Binding<Double>,
    isEnabled: Bool = true,
    resolve: @escaping ZoomResolver = { $0.proposedZoom },
  ) -> some View {
    self.modifier(
      PinchGestureModifier(
        initialZoom: zoom.wrappedValue,
        zoom: zoom,
        isEnabled: isEnabled,
        resolve: resolve,
      )
    )
  }
}

extension View {

  /// Adds an internally owned pinch gesture seeded from an initial zoom.
  ///
  /// Use this overload when no external binding owns the zoom value. The
  /// resolver receives every proposal and returns the value CanvasKit should
  /// retain for the next gesture update.
  ///
  /// - Parameters:
  ///   - initialZoom: The zoom from which the first pinch begins.
  ///   - isEnabled: Whether the pinch gesture can begin.
  ///   - resolve: Resolves each gesture proposal. Return
  ///     ``ZoomProposal/proposedZoom`` to accept it unchanged.
  public func onPinchGesture(
    initialZoom: Double = 1,
    isEnabled: Bool = true,
    resolve: @escaping ZoomResolver,
  ) -> some View {
    self.modifier(
      PinchGestureModifier(
        initialZoom: initialZoom,
        isEnabled: isEnabled,
        resolve: resolve,
      )
    )
  }
}

/// A legacy pinch callback that can replace a proposed zoom or return `nil` to accept it.
@available(
  *, deprecated,
  message: "Use ZoomResolver, whose ZoomProposal makes proposal and resolution semantics explicit."
)
public typealias ZoomUpdate = (Double, InteractionPhase) -> Double?

extension View {

  /// Adds a pinch gesture using the legacy two-source configuration.
  ///
  /// When `zoom` is supplied, its current value takes precedence over
  /// `initial`. Prefer one of the ownership-specific overloads so the initial
  /// source of truth is explicit.
  @available(
    *, deprecated,
    message: "Use onPinchGesture(zoom:isEnabled:resolve:) for externally owned zoom, or onPinchGesture(initialZoom:isEnabled:resolve:) for internally owned zoom."
  )
  public func onPinchGesture(
    initial: Double = 1,
    zoom: Binding<Double>? = nil,
    isEnabled: Bool = true,
    didUpdateZoom: @escaping ZoomUpdate,
  ) -> some View {
    self.modifier(
      PinchGestureModifier(
        initialZoom: zoom?.wrappedValue ?? initial,
        zoom: zoom,
        isEnabled: isEnabled,
        resolve: { proposal in
          didUpdateZoom(proposal.proposedZoom, proposal.phase)
            ?? proposal.proposedZoom
        },
      )
    )
  }
}
