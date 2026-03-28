//
//  CanvasDemoApp.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 9/1/2026.
//

//import SwiftUI
//
//@main
//struct CanvasDemoApp: App {
//  var body: some Scene {
//    DocumentGroup(newDocument: CanvasDemoDocument()) { file in
//      ContentView()
//        //            .environment(store)
//        //            .environment(\.popup, popup)
//        //            .readModifierKeys()
//        .environment(\.artwork, file.$document.text)
//        .focusedSceneValue(\.artwork, file.$document.text)
//        .focusedSceneValue(\.documentURL, file.fileURL)
//    }
//  }
//}
//
//extension EnvironmentValues {
//  @Entry var artwork: Binding<String> = .constant("Hello")
//}
//
//extension FocusedValues {
//  @Entry var artwork: Binding<String>? = nil
//  @Entry var documentURL: URL? = nil
//}
