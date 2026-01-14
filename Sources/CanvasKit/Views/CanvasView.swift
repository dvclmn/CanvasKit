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

          /// This `.frame()` is important to make sure the area *containing*
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

          .addInfoBarItems(CanvasInfoItem.buildItems(from: canvasHandler))

          .task(id: canvasSize) {
            canvasHandler.updateCanvasSize(canvasSize)
          }

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
        canvasHandler.panGesture.update(delta, phase: phase)
      }
      .zoomGesture(zoom: $canvasHandler.zoomGesture, isEnabled: true)

      .marqueeDrag(
        isEnabled: true,
        dragThreshold: canvasHandler.pointerState.dragThreshold
      ) {
        canvasHandler.pointerState.update($0, phase: $1)
      }

      /// This should only be on when e.g. the Pan Hand tool is selected
      .cumulativeDrag(
        canvasHandler.cumulativeDragPanBinding(),
        isEnabled: true,
        minDragDistance: canvasHandler.pointerState.dragThreshold
      )

      .onContinuousHover { phase in
        canvasHandler.pointerState.update(hoverPhase: phase)
      }

      .infoBarView(isEnabled: showsInfoBar)

      .environment(\.canvasGeometry, canvasHandler.geometry)
      .environment(\.canvasPan, canvasHandler.pan)
      .environment(\.canvasZoom, canvasHandler.zoom)
      .environment(\.canvasZoomRange, canvasHandler.zoomRange)
      .environment(\.pointerState, canvasHandler.pointerState)

    //      .environment(\.pointerInteraction, canvasHandler.pointerState.currentInteraction)

    //      .environment(\.isResizingCanvas, store.canvasHandler.resizeHandler.isDragging)

    //      .task(id: modifierKeys) {
    //        canvasHandler.interactions.modifiersHeld = modifierKeys
    //      }

    //      .debugTextOverlay {
    //        "Checking Geometry:\n\(canvasHandler.geometry)"
    //      }
    //      .backgroundTint(.yellow)
    //      .disabled(!canvasHandler.geometry.isEitherZero)

  }
}

extension CanvasView {

}
