//
//  ToolButtonStyle.swift
//  CanvasKit
//
//  Created by Dave Coleman on 25/8/2026.
//

import SwiftUI
private import ViewTools

extension ButtonStyle where Self == ToolButton {
  static func toolButton(width: CGFloat) -> Self { Self(width: width) }
}

struct ToolButton: ButtonStyle {
  @Environment(\.isEmphasised) private var isEmphasised
  //  @Environment(\.strokeConfig) private var strokeConfig
  //  @Environment(\.isInControlGroup) private var isInControlGroup
  //  @Environment(\.isEnabled) private var isEnabled
  //  @Environment(\.frameHeight) private var frameHeight
  //  @Environment(\.isBackgroundHidden) private var isBackgroundHidden
  
//  public init() {}
  
  // Tool button is square, just one length needed
  let width: CGFloat
  
  func makeBody(configuration: Configuration) -> some View {
    
    configuration.label
      .symbolVariant(.fill)
      .symbolRenderingMode(.hierarchical)
      .frame(width: width, height: width)
      .background {
        if isEmphasised {
          Capsule()
//            .fill(TintShapeStyle())
          //            RoundedRectangle(cornerRadius: 5)
          //              .fill(.quaternary)
        }
      }
      .contentShape(.capsule)
//      .tint(.gray)
//      .border(Color.green.opacity(0.3))
  }
}
