//
//  CanvasDimming.swift
//  CanvasKit
//
//  Created by Dave Coleman on 5/8/2026.
//

//import SwiftUI
//
//struct CanvasOutsideDimmer: View {
//  let cornerRadius: Double
//  let dimmingAmount: Double
//  let colour: Color
//  
//  private let outsideExtent: CGFloat = 100_000
//  
//  var body: some View {
//    GeometryReader { proxy in
//      OutsideCanvasShape(
//        size: proxy.size,
//        cornerRadius: cornerRadius,
//        outsideExtent: outsideExtent,
//      )
//      .fill(colour.opacity(dimmingAmount), style: .init(eoFill: true))
//    }
//    .allowsHitTesting(false)
//  }
//}
//
//struct OutsideCanvasShape: Shape {
//  let size: CGSize
//  let cornerRadius: Double
//  let outsideExtent: CGFloat
//  
//  func path(in rect: CGRect) -> Path {
//    let canvasRect = CGRect(origin: .zero, size: size)
//    let outsideRect = canvasRect.insetBy(dx: -outsideExtent, dy: -outsideExtent)
//    
//    return Path { path in
//      path.addRect(outsideRect)
//      path.addRoundedRect(
//        in: canvasRect,
//        cornerSize: CGSize(width: cornerRadius, height: cornerRadius),
//      )
//    }
//  }
//}
