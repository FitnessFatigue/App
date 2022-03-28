//
//  GraphLines.swift
//  SwiftUIChartsPlayground
//
//  Created by Matthew Roche on 25/11/2021.
//

import SwiftUI

struct GraphLines: View {

    @Binding var yMin: CGFloat
    @Binding var yMax: CGFloat
    var paddingX: CGFloat
    var paddingY: CGFloat
    var paddingForLabels: CGFloat
    var lineLabels: [CGFloat]
    
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
                
                func labelValueToHeight(_ label: CGFloat) -> CGFloat {
                    ((label - yMin) / (yMax - yMin))
                }
                
                for lineLabel in lineLabels {
                    context.stroke(
                        Path { path in
                            let height = (labelValueToHeight(lineLabel) * size.height)
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
    @State static var yMin: CGFloat = -2
    @State static var yMax: CGFloat = 12
    static var previews: some View {
        GraphLines(yMin: $yMin, yMax: $yMax, paddingX: 20, paddingY: 20, paddingForLabels: 20, lineLabels: [0, 5, 10]).frame(width: .infinity, height: 200)
    }
}
