//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

//import BaseUI
import CoreTools
import GestureKit
import SwiftUI

public struct CanvasView<Content: View>: View {
  @Environment(\.isDebugMode) private var isDebugMode
  @Environment(\.modifierKeys) private var modifierKeys
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.viewportRect) private var viewportRect

  //  @State private var hasZoomedToFit: Bool = false

  @State var canvasHandler = CanvasHandler()

  let canvasSize: CGSize
  let showsInfoBar: Bool
  let content: Content

  public init(
    canvasSize: CGSize,
    showsInfoBar: Bool = true,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = canvasSize
    self.showsInfoBar = showsInfoBar
    self.content = content()
  }

  public var body: some View {

    if let viewportRect {

      Rectangle()
        .fill(.clear)
        //      .viewSize(
        //        capture: .sizeAndSafeInsets,
        //        mode: .debounce(0.1)
        //      ) { geometry in
        //        canvasHandler.updateViewportRect(geometry.rect)
        //      }
        .overlay {
          content
            .frame(
              width: canvasHandler.geometry.canvasSize.width,
              height: canvasHandler.geometry.canvasSize.height
            )
            .coordinateSpace(.canvasIdentity)

            .modifier(CanvasOutlineModifier())
            .scaleEffect(canvasHandler.zoomClamped)
            //        .rotationEffect(canvasHandler.rotation)
            .offset(canvasHandler.pan)

            /// This frame modifier is important to make sure the area containing
            /// the Canvas is spread out to the edges
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
//            .background(.black.opacity(0.8))
            .drawingGroup(opaque: true)
          //          .coordinateSpace(.canvasIdentity)
          /// Send modifiers to interacitons handler

          /// This drives the resizing callbacks, and means I don't have to pass
          /// them through multiple View inits. Can just keep them in the
          /// `ResizeHandler`, and make sure they're 'activated'(?) here.
          //        .onAppear {
          //          if canvasHandler.resizeHandler.didEndResize == nil {
          //            canvasHandler.resizeHandler.didEndResize = didEndResize
          //          }
          //          if canvasHandler.resizeHandler.didChangeResize == nil {
          //            canvasHandler.resizeHandler.didChangeResize = didChangeResize
          //          }
          //        }

          // MARK: - Resize
          //        .overlay {
          //          CanvasResizeView(
          //            store: $canvasHandler.resizeHandler,
          //            isEnabled: canvasHandler.isDragAllowed(.resize),
          //          )
          //        }

          // MARK: - Hover

          // MARK: - Keyboard keys
          // TODO: May need to bring this back
          //        .keysHeld(canvasHandler.interactions.keysToWatch) { keys in
          //          canvasHandler.handleKeysHeld(keys)
          //        }

          //    }  // END geo reader

        }

        .panGesture(isEnabled: true) { delta, phase, modifiers in
          canvasHandler.panGesture.updateDelta(delta, phase: phase)
        }
        .zoomGesture(zoom: $canvasHandler.zoomGesture.value.toBindingDouble, isEnabled: true)
        //      .zoomGesture(zoom: $canvasHandler.zoomGesture, isEnabled: true)

        .tapDragGesture(
          rect: canvasHandler.dragRectBinding(),
          //        behavior: .marquee(drawMarquee: true),
          behavior: canvasHandler.activeDragType,
          //        behavior: .continuous(axes: .all),
          minimumDistance: canvasHandler.pointerDrag.dragThreshold,
          didUpdateTap: { location in
            canvasHandler.pointerTap.value = location
          }
        )
        //      .debugTextOverlay(
        //        "Pointer interaction: \(canvasHandler.currentPointerInteraction?.name, default: "nil")",
        //        "Binding Rect: \(canvasHandler.dragRectBinding().wrappedValue?.displayString, default: "nil")",
        //        "Pan Value: \(canvasHandler.panGesture.pan.displayString)"
        //      )

        /// This is (I think?) a surprinsingly heavy modifier
        //      .onContinuousHover { phase in
        //              guard !canvasHandler.pointerState.isDragging else { return }
        //              canvasHandler.pointerState.update(hoverPhase: phase)
        //      }

        /// I may bring this back, but I need to fix infobar so that the PreferenceKey reduce stuff
        /// is working properly. Also, I'd like if I can to decouple BaseUI and CanvasKit
        //      .addInfoBarItems(
        //        CanvasInfoItem.self,
        //        source: canvasHandler,
        //        format: .default,
        //        isEnabled: showsInfoBar
        //      )

        //      .infoBarView(isEnabled: showsInfoBar)
        //      .infoBarStyle(for: .item, .iconOnly)

        .environment(\.canvasGeometry, canvasHandler.geometry)
        .environment(\.panOffset, canvasHandler.pan)
        .environment(\.zoomLevel, canvasHandler.zoomClamped)

        .task(id: canvasSize) { canvasHandler.updateCanvasSize(canvasSize) }
        .task(id: zoomRange) { canvasHandler.zoomRange = zoomRange }
        .task(id: viewportRect) { canvasHandler.updateViewportRect(viewportRect) }

    } else {
      Text("No Viewport rect provided")
    }

  }
}

extension CanvasView {

}
