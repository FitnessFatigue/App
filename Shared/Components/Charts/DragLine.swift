//
//  DragLine.swift
//  Intervals (iOS)
//
//  Created by Matthew Roche on 19/12/2021.
//

import SwiftUI

struct DragLine: View {
    
    var dragPoint: CGPoint?
    
    var body: some View {
        GeometryReader { geo in
            
            Canvas { context, size in
                
                if dragPoint != nil {
                    context.stroke(Path(CGRect(origin: dragPoint!, size: CGSize(width: 1, height: geo.size.height))), with: .color(.orange))
                }
                
            }
            
        }
    }
}
