//
//  ToolCapability.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

struct ToolCapability {
  let interactionKind: InteractionKind
  let adjustmentKind: AdjustmentKind
  
  init(
    interaction: InteractionKind,
    adjustment: AdjustmentKind
  ) {
    self.interactionKind = interaction
    self.adjustmentKind = adjustment
  }
}

//extension ToolCapability {
//  /// Where Select is the default tool
//  static let `default`: Self = .init(
//    /// A tool will need to *explicitly* opt out of these standard
//    /// permitted interaction kinds, to disable them.
////    interaction: [.swipe, .pinch, .rotation],
////    adjustment: [.t]
//    interaction: <#T##InteractionKind#>, adjustment: <#T##AdjustmentKind#>
//  )
//}



//extension ToolCapability {
//  func () -> Bool {
//    
//  }
//}
