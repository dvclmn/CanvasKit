//
//  CanvasContentView.swift
//  CanvasKit
//
//  Created by Dave Coleman on 23/4/2026.
//

import SwiftUI

struct CanvasContentView: View {
  var body: some View {

    Canvas { context, size in
      context.fill(
        Path(
          ellipseIn: CGRect(origin: .zero, size: CGSize(width: 200, height: 100))
        ),
        with: .color(.blue),
      )
    }
  }
}
