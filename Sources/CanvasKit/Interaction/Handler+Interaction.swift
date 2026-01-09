//
//  Model+InteractionRules.swift
//  BaseComponents
//
//  Created by Dave Coleman on 19/7/2025.
//

import SharedHelpers
import GestureKit
import SwiftUI

public struct InteractionHandler {

  /// Important: There is a difference between handling the
  /// current active interaction, and handling which interactions
  /// are allowed to be initiated at any given time.
  public var interaction: Interaction = .none

  /// This forces the caller to define which is allowed.
  /// If not defined, none will work.
  public var allowedDragGesture: GestureKind.Meta = .none
  //#if canImport(AppKit)
  public var keysHeld: Keys = []
  public var modifiersHeld: Modifiers = []

  let keysToWatch: Set<KeyEquivalent> = [.space]
  //#endif
}
