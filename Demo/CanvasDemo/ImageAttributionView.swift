//
//  SunflowerAttributionView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 15/5/2026.
//

import SwiftUI

struct ImageAttributionView: View {

  let image: SampleImage
  var body: some View {

    if let attribution = image.attribution {
      Text(LocalizedStringKey(attribution))
        .tint(.secondary)
        .font(.callout)
        .foregroundStyle(.tertiary)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 5))
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
    
  }
}
