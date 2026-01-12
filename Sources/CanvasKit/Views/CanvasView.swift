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
      .viewSize(mode: .debounce(0.1)) { size in
        canvasHandler.updateViewportSize(size)
      }
      
      .overlay {
        //    ZStack {
        /// Don't know why this extra zstack is neccesary? Layer order was wrong, when removed
//        ZStack {
          content
//        }
        .frame(
          width: canvasHandler.geometry.canvasSize.width,
          height: canvasHandler.geometry.canvasSize.height
        )
        //        .clipShape(.rect(cornerRadius: canvasHandler.cornerRounding))
        .modifier(CanvasOutlineModifier(canvasHandler: canvasHandler))
        //        .scaleEffect(canvasHandler.zoom)
        //        .rotationEffect(canvasHandler.rotation)
        .offset(canvasHandler.panOffset)
        //        .offset(canvasHandler.gestureHandler.panOffset)

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

        // MARK: - Gestures

        
        //        .panAndZoom(interactions: $canvasHandler.interactions)
        //        .panAndZoom(geometry: canvasHandler.geometry)
        //        .modifier(
        //          CanvasGesturesModifier(
        //            canvasHandler: $canvasHandler
        //          )
        //        )

        // MARK: - Drag Types
        //        .cumulativeDrag(
        //          $canvasHandler.panHandler.pan,
        //          isEnabled: canvasHandler.isDragAllowed(.pan),
        //          minDragDistance: canvasHandler.dragTolerance
        //        )

        //                .marqueeDrag(
        //                  isEnabled: canvasHandler.interactions.isAllowed(.drag),
        ////                  isEnabled: canvasHandler.isDragAllowed(.select),
        //                  dragThreshold: canvasHandler.dragTolerance
        //                ) { interaction, phase in
        //                  canvasHandler.interactions.updateGesture(
        //                    interaction,
        //                    phase: phase,
        //                    modifiers: modifierKeys
        //                  )
        ////                  canvasHandler.handleDrag(type: .select, phase)
        //                }

        // MARK: - Resize
        //        .overlay {
        //          CanvasResizeView(
        //            store: $canvasHandler.resizeHandler,
        //            isEnabled: canvasHandler.isDragAllowed(.resize),
        //          )
        //        }

        // MARK: - Hover
        //                .onContinuousHover { phase in
        //                  canvasHandler.handleHover(phase)
        //                }

        // MARK: - Keyboard keys
        // TODO: May need to bring this back
        //        .keysHeld(canvasHandler.interactions.keysToWatch) { keys in
        //          canvasHandler.handleKeysHeld(keys)
        //        }

        //    }  // END geo reader
      }
    
      .panGesture(isEnabled: true) { stream in
        canvasHandler.panGesture = stream
        //          canvasHandler.panGesture.update(offset, phase: phase)
      }

      .infoBarView(isEnabled: showsInfoBar)

      .environment(\.canvasPan, canvasHandler.panOffset)
      //            .environment(\.canvasZoom, canvasHandler.zoom)
      //            .environment(\.canvasZoomRange, canvasHandler.zoomRange)

      //      .environment(\.isResizingCanvas, store.canvasHandler.resizeHandler.isDragging)
      //      .environment(\.pointerPhase, canvasHandler.pointerPhase)

      //      .task(id: modifierKeys) {
      //        canvasHandler.interactions.modifiersHeld = modifierKeys
      //      }

      .debugTextOverlay {
        "Checking Geometry:\n\(canvasHandler.geometry)"
      }
      .backgroundTint(.yellow)
      .disabled(!canvasHandler.geometry.isEitherZero)

  }
}

extension CanvasView {

}
