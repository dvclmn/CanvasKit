//
//  CanvasContentView.swift
//  CanvasKit
//
//  Created by Dave Coleman on 23/4/2026.
//

//import SwiftUI
//
//struct CanvasContentView: View {
//  var body: some View {
//
//    Canvas { context, size in
//      context.fill(
//        Path(
//          ellipseIn: CGRect(origin: .zero, size: CGSize(width: 200, height: 100))
//        ),
//        with: .color(.blue),
//      )
//    }
//  }
//}
import SwiftUI

struct CanvasContentView: View {
  var body: some View {
    Canvas {
      context,
      size in
      let width = size.width
      let height = size.height

      // Square
      let squareSize = width * 0.2
      let rect = CGRect(
        origin: CGPoint(x: width * 0.1, y: height * 0.2),
        size: CGSize(
          width: squareSize,
          height: squareSize,
        ),
      )
      context.fill(Path(rect), with: .color(.mint.opacity(0.85)))

      // Circle
      let circleSize = width * 0.6
      let pillRect = CGRect(
        x: width * 0.3,
        y: height * 0.65,
        width: circleSize,
        height: circleSize,
      )
      context.fill(Path(ellipseIn: pillRect), with: .color(.indigo))

      // Triangle
      var trianglePath = Path()
      trianglePath.move(to: CGPoint(x: width * 0.7, y: height * 0.1))
      trianglePath.addLine(to: CGPoint(x: width * 0.9, y: height * 0.5))
      trianglePath.addLine(to: CGPoint(x: width * 0.5, y: height * 0.5))
      trianglePath.closeSubpath()
      context.fill(trianglePath, with: .color(.brown))

    }
    .background(Color.indigo.opacity(0.15))
  }
}
