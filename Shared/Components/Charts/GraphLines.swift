//
//  GraphLines.swift
//  SwiftUIChartsPlayground
//
//  Created by Matthew Roche on 25/11/2021.
//

import SwiftUI

struct GraphLines: View {

    var yMin: CGFloat?
    var yMax: CGFloat?
    var paddingX: CGFloat
    var paddingY: CGFloat
    var paddingForLabels: CGFloat
    var lineHeights: [CGFloat]
    
    var body: some View {
        GeometryReader { geo in
        
            // Graph lines
            Canvas { context, size in
                
                
                
                func adjustCoordinates(_ point: CGPoint) -> CGPoint {
                    let invertedY = size.height - point.y
                    return CGPoint(
                        x: (point.x / size.width * (size.width - (2 * paddingX + paddingForLabels))) + paddingX + paddingForLabels,
                        y: (invertedY / size.height * (size.height - (2 * paddingY + paddingForLabels))) + paddingY
                    )
                }
                
                for lineHeight in lineHeights {
                    context.stroke(
                        Path { path in
                            let height = size.height * lineHeight
                            path.move(to: adjustCoordinates(CGPoint(x: 0, y: height)))
                            path.addLine(to: adjustCoordinates(CGPoint(x: geo.size.width, y: height)))
                        },
                        with: .color(.black),
                        lineWidth: 1)
                }
                
            }
        }
    }
}

struct GraphLines_Previews: PreviewProvider {
    static var previews: some View {
        GraphLines(yMin: 0, yMax: 20, paddingX: 20, paddingY: 20, paddingForLabels: 20, lineHeights: [0, 1/3, 2/3, 1]).frame(width: .infinity, height: 200)
    }
}
