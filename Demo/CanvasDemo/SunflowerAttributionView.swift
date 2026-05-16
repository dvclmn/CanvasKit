//
//  SunflowerAttributionView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 15/5/2026.
//

import SwiftUI

struct SunflowerAttributionView: View {

  var body: some View {
    
    Text(
      "Photo by [Linus Belanger](https://unsplash.com/@linusbelanger?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/photos/a-single-sunflower-blooms-against-a-bright-blue-sky-ysB8453OSbI?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)"
    )
    .tint(.secondary.opacity(0.85))
    .font(.callout)
    .foregroundStyle(.tertiary)
    .padding(.horizontal, 6)
    .padding(.vertical, 3)
    //      .background(.gray.opacity(0.15))
    .background(.regularMaterial)
    .clipShape(.rect(cornerRadius: 5))
    .padding()
    
  }
}
