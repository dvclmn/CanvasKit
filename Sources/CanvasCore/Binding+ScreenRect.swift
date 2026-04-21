//
//  Binding+ScreenRect.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 18/3/2026.
//

//import SwiftUI
//
//extension Binding where Value == Size<ScreenSpace> {
//  public var toBindingScreenRect: Binding<Rect<ScreenSpace>> {
//    return Binding<Rect<ScreenSpace>> {
//      wrappedValue.toRectZeroOrigin
//    } set: {
//      wrappedValue = $0.size
//    }
//  }
//}
//
//extension Binding where Value == Size<ScreenSpace>? {
//  public var toBindingScreenRect: Binding<Rect<ScreenSpace>?> {
//    return Binding<Rect<ScreenSpace>?> {
//      wrappedValue?.toRectZeroOrigin
//    } set: {
//      wrappedValue = $0?.size
//    }
//  }
//}
//
//// MARK: - to standard CGRect
//extension Binding where Value == Size<ScreenSpace> {
//  public var toBindingCGRect: Binding<CGRect> {
//    return Binding<CGRect> {
//      wrappedValue.toCGRectZeroOrigin
//    } set: {
//      wrappedValue.height = $0.height
//      wrappedValue.width = $0.width
//    }
//  }
//}
//
//extension Binding where Value == Size<ScreenSpace>? {
//  public var toBindingCGRect: Binding<CGRect?> {
//    return Binding<CGRect?> {
//      wrappedValue?.toCGRectZeroOrigin
//    } set: {
//      guard let width = $0?.width, let height = $0?.height else { return }
//      wrappedValue?.height = height
//      wrappedValue?.width = width
//    }
//  }
//}
//
//extension Binding where Value == Rect<ScreenSpace>? {
//  public var toBindingCGRect: Binding<CGRect?> {
//    return Binding<CGRect?> {
//      wrappedValue?.cgRect
//    } set: {
//      guard let rect = $0 else { return }
//      wrappedValue = rect.screenRect
//    }
//  }
//}
