//
//  PointerStateEnvironmentModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

private import CoreTools
import SwiftUI

struct PointerEnvironmentModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store
    @Environment(\.explicitCanvasSize) private var explicitCanvasSize

//  let explicitCanvasSize: Size<CanvasSpace>?
  //  let mapper: CoordinateSpaceMapper
  //  let resolvedSize: Size<CanvasSpace>
  func body(content: Content) -> some View {
    content
      //      .environment(\.canvasCoordinateSpaceMapper, mapper)
      .environment(\.pointerTap, snapshot?.pointer.tap)
      .environment(\.pointerDrag, snapshot?.pointer.drag)
      .environment(\.pointerHover, snapshot?.pointer.hover)
  }
}

extension PointerEnvironmentModifier {

  //  private var mapper: CoordinateSpaceMapper? {
  //    guard let frame = store.artworkFrame,
  //      let size = store.resolvedCanvasSize(for: explicitCanvasSize)
  //    else { return nil }
  //    return .init(frame: frame, canvasSize: size)
  //  }

  private var snapshot: PointerMappedSnapshot? {
    guard let mapper = store.coordinateSpaceMapper(in: explicitCanvasSize) else { return nil }
    //    guard let mapper else { return nil }
    return .createMapped(
      mapper: mapper,
      pointerState: store.pointer,
    )
  }
}
