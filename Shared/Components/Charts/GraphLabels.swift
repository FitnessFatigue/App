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
    var lineHeights: [CGFloat]
    
    
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
                
                let yDistance = yMax - yMin
                for lineHeight in lineHeights {
                    let y = yMin + yDistance * lineHeight
                    context.draw(
                        Text("\(Int(y))"),
                        at: adjustCoordinates(CGPoint(x: 0,y: size.height * lineHeight))
                    )
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
                        size: CGSize(width: 60, height: 10)
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
                        size: CGSize(width: 60, height: 10)
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
        GraphLabels(xMin: $xMin, xMax: $xMax, yMin: $yMin, yMax: $yMax, paddingX: 20, paddingY: 20, paddingForLabels: 20, lineHeights: [0, 1/3, 2/3, 1]).frame(width: .infinity, height: 200)
    }
}
