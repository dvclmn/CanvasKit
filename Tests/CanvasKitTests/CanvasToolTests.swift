//import Testing
//@testable import CanvasKit

//struct CanvasKitTests {
//
//  let handler = CanvasHandler()
//  
//  @Test func canvasHandlerStartsWithInitialPointerState() {
//    #expect(handler.pointer == .initial)
//  }
//
//  @Test func defaultToolCapabilitiesCoverCanvasBasics() {
//    #expect(StubTool().inputCapabilities == .canvasBasics)
//  }
//
//  @Test func selectToolClaimsSelectionCapabilities() {
//    #expect(SelectTool().inputCapabilities == .selection)
//  }
//
//  @Test func panAndZoomToolsClaimTheirOwnPointerCapabilities() {
//    #expect(PanTool().inputCapabilities == .pan)
//    #expect(ZoomTool().inputCapabilities == .zoom)
//  }
//
//  @Test func interactionAdjustmentReportsItsAdjustmentKind() {
//    let point = Point<ScreenSpace>(fromPoint: .zero)
//    let size = Size<ScreenSpace>(fromCGSize: .zero)
//    let rect = Rect<ScreenSpace>(from: point, to: point)
//
//    #expect(InteractionAdjustment.transform(.translation(size)).kind == .translation)
//    #expect(InteractionAdjustment.transform(.scale(1.5)).kind == .scale)
//    #expect(InteractionAdjustment.pointer(.tap(point)).kind == .tapLocation)
//    #expect(InteractionAdjustment.pointer(.drag(rect)).kind == .dragRect)
//    #expect(InteractionAdjustment.none.kind == nil)
//  }
//}
//
//private struct StubTool: CanvasTool {
//  let kind: CanvasToolKind = .init(rawValue: "stub")
//  let name = "Stub"
//  let icon = "questionmark"
//
//  var dragBehaviour: PointerDragBehaviour { .none }
//
//  func resolvePointerStyle(
//    context: InteractionContext
//  ) -> PointerStyleCompatible { .default }
//
//  func resolvePointerInteraction(
//    context: InteractionContext,
//    currentTransform: TransformState,
//  ) -> ToolResolution {
//    .none
//  }
//}
