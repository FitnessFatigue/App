//
//  GraphLabels.swift
//  SwiftUIChartsPlayground
//
//  Created by Matthew Roche on 25/11/2021.
//

import SwiftUI

struct GraphLabels: View {
    
    @Binding var xMin: Date
    @Binding var xMax: Date
    @Binding var yMin: CGFloat
    @Binding var yMax: CGFloat
    
    var paddingX: CGFloat
    var paddingY: CGFloat
    var paddingForLabels: CGFloat
    var lineLabels: [CGFloat]
    
    
    var body: some View {
        GeometryReader { geo in
            
            Canvas { context, size in
                
                func adjustCoordinates(_ point: CGPoint) -> CGPoint {
                    let invertedY = size.height - point.y
                    return CGPoint(
                        x: (point.x / size.width * (size.width - (2 * paddingX))) + paddingX,
                        y: (invertedY / size.height * (size.height - (2 * paddingY + paddingForLabels))) + paddingY
                    )
                }
                
                func labelValueToHeight(_ label: CGFloat) -> CGFloat {
                    (label - yMin) / (yMax - yMin)
                }
                
                
                for (index, lineLabel) in lineLabels.enumerated() {
                    if index == 0 ||
                        ((size.height * labelValueToHeight(lineLabels[index-1])) - (size.height * labelValueToHeight(lineLabel))) > 1 {
                        context.draw(
                            Text(lineLabel, format: .number),
                            at: adjustCoordinates(CGPoint(
                                x: 0,
                                y: size.height * labelValueToHeight(lineLabel))
                            )
                        )
                    }
                }
                
                context.draw(
                    Text(xMin.formatted(date: .numeric, time: .omitted))
                        .font(.caption2),
                    in: CGRect(
                        origin: adjustCoordinates(
                            CGPoint(
                                x: (paddingForLabels),
                                y: (-paddingForLabels + 5)
                            )
                        ),
                        size: CGSize(width: 70, height: 10)
                    )
                )
                
                context.draw(
                    Text(xMax.formatted(date: .numeric, time: .omitted))
                        .font(.caption2),
                    in: CGRect(
                        origin: adjustCoordinates(
                            CGPoint(
                                x: (size.width - 60),
                                y: (-paddingForLabels + 5)
                            )
                        ),
                        size: CGSize(width: 70, height: 10)
                    )
                )
                
            }
        }
    }
}

struct GraphLabels_Previews: PreviewProvider {
    @State static var xMin: Date = Calendar.current.date(byAdding: .day, value: -15, to: Date())!
    @State static var xMax: Date = Date()
    @State static var yMin: CGFloat = -2
    @State static var yMax: CGFloat = 12
    static var previews: some View {
        GraphLabels(xMin: $xMin, xMax: $xMax, yMin: $yMin, yMax: $yMax, paddingX: 20, paddingY: 20, paddingForLabels: 20, lineLabels: [0, 5, 10]).frame(width: .infinity, height: 200)
    }
}
