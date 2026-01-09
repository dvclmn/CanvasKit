//
//  CanvasContentView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

//import SwiftUI
//
//public struct BoxPrintView: View {
//  
//  public var body: some View {
//    
//    content
//      .frame(
//        width: canvasHandler.canvasSize?.width,
//        height: canvasHandler.canvasSize?.height
//      )
//      .clipShape(.rect(cornerRadius: canvasHandler.cornerRounding))
//      .modifier(CanvasOutlineModifier(canvasHandler: canvasHandler))
//      .scaleEffect(canvasHandler.zoomHandler.zoom)
//      .rotationEffect(canvasHandler.rotationHandler.rotation)
//      .offset(canvasHandler.panHandler.pan)
//    
//    /// This `.frame()` is important to make sure the area *containing*
//    /// the Canvas is spread out to the edges
//      .frame(maxWidth: .infinity, maxHeight: .infinity)
//      .allowsHitTesting(false)
//      .drawingGroup()
//    
//  }
//}
//#if DEBUG
//@available(macOS 15, iOS 18, *)
//#Preview(traits: .size(.normal)) {
//  BoxPrintView()
//}
//#endif

