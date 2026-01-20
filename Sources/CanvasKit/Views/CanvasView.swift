//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import BaseUI
import CoreTools
import GestureKit
import SwiftUI

public struct CanvasView<Content: View>: View {
  @Environment(\.isDebugMode) private var isDebugMode
  @Environment(\.modifierKeys) var modifierKeys

  //  @State private var hasZoomedToFit: Bool = false

  @State var canvasHandler = CanvasHandler()

  let canvasSize: CGSize
  let showsInfoBar: Bool
  let content: Content
  //  let didChangeResize: ResizeOutput
  //  let didEndResize: ResizeOutput

  public init(
    canvasSize: CGSize,
    //    handler: Binding<CanvasHandler>,
    showsInfoBar: Bool = true,
    @ViewBuilder content: @escaping () -> Content,
    //    didChangeResize: @escaping ResizeOutput = { _, _ in },
    //    didEndResize: @escaping ResizeOutput = { _, _ in },
  ) {
    //    self._canvasHandler = handler
    self.canvasSize = canvasSize
    self.showsInfoBar = showsInfoBar
    self.content = content()
    //    self.didChangeResize = didChangeResize
    //    self.didEndResize = didEndResize
  }

  public var body: some View {

    Rectangle()
      .fill(.clear)
      .viewSize(mode: .debounce(0.1)) { size in
        canvasHandler.updateViewportSize(size)
      }

      .overlay {
        content
          .frame(
            width: canvasHandler.geometry.canvasSize.width,
            height: canvasHandler.geometry.canvasSize.height
          )

          .modifier(CanvasOutlineModifier())
          .scaleEffect(canvasHandler.zoom)
          //        .rotationEffect(canvasHandler.rotation)
          .offset(canvasHandler.pan)

          /// This frame modifier is important to make sure the area containing
          /// the Canvas is spread out to the edges
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .allowsHitTesting(false)
          .drawingGroup()
          //        .shaderEffect(
          //          .chromaticAberration(
          //            .init(
          //              red: 0.9,
          //              blue: 0.3,
          //              strength: 0.8
          //            )
          //          )
          //        )

          .background(.black.opacity(0.8))

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

      .panGesture(isEnabled: true) { delta, phase in
        canvasHandler.panGesture.updateDelta(delta, phase: phase)
      }
      .zoomGesture(zoom: $canvasHandler.zoomGesture, isEnabled: true)

      .tapDragGesture(
        rect: canvasHandler.dragRectBinding(),
        //        behavior: .marquee(drawMarquee: true),
        behavior: canvasHandler.activeDragType,
        //        behavior: .continuous(axes: .all),
        isEnabled: true,
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
      .onContinuousHover { phase in
        //              guard !canvasHandler.pointerState.isDragging else { return }
        //              canvasHandler.pointerState.update(hoverPhase: phase)
      }

      .addInfoBarItems(
        CanvasInfoItem.self,
        source: canvasHandler,
        format: .short
      )

      .infoBarView(isEnabled: showsInfoBar)
      .infoBarStyle(for: .item, .iconOnly)

      .environment(\.canvasGeometry, canvasHandler.geometry)
      .environment(\.canvasPan, canvasHandler.pan)
      .environment(\.canvasZoom, canvasHandler.zoom)
      .environment(\.canvasZoomRange, canvasHandler.zoomRange)

      .task(id: canvasSize) {
        canvasHandler.updateCanvasSize(canvasSize)
      }
      //      .task(id: modifierKeys) {
      //        canvasHandler.interactions.modifiersHeld = modifierKeys
      //      }

      .onAppear {
        if isPreview {
          canvasHandler.panGesture.update(CGSize(30, 80), phase: .ended)
        }
      }

  }
}

extension CanvasView {

}
