//
//  ResizableCanvasView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 1/8/2025.
//

import SwiftUI

//public struct ResizeModifier: ViewModifier {
//  
//  public func body(content: Content) -> some View {
//    content
//      .overlay {
//        
//        Text("Resize phase: \(resizingPhase?.displayString ?? "nil")")
//          .quickBackground()
//        
//        RoundedRectangle(cornerRadius: Styles.sizeTiny)
//          .fill(.clear)
//          .stroke(.blue, lineWidth: canvasHandler.removeZoom(from: 1))
//          .contentShape(.rect.inset(by: -60))
//          .modifier(
//            ResizeDragModifier(
//              anchor: .trailing,
//              initialRect: canvasHandler.canvasContext?.canvasFrameInViewport ?? .zero,
//              isEnabled: true
//            ) { phase in
//              resizingPhase = phase
//            }
//          )
//          .frameFromRect(canvasHandler.canvasContext?.canvasFrameInViewport)
//        //        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        Rectangle()
//          .fill(.brown.opacityLow)
//          .frameFromRect(resizingPhase?.rect)
//          .allowsHitTesting(false)
//      } // END overlay
//    
//    
//  }
//}
//extension View {
//  public func example() -> some View {
//    self.modifier(ExampleModifier())
//  }
//}

//public struct ResizableCanvas<Content: View>: View {
//  
//  @Binding var size: CGSize
//  let content: Content
//  
//  public init(
//    size: Binding<CGSize>,
//    @ViewBuilder content: @escaping () -> Content
//  ) {
//    self._size = size
//    self.content = content()
//  }
//  
//  public var body: some View {
//    
//    ZStack {
//      
//      content
//      
//      BoundingOutline()
//    }
//  }
//}
