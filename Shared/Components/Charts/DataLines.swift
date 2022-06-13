//
//  DataLines.swift
//  SwiftUIChartsPlayground
//
//  Created by Matthew Roche on 25/11/2021.
//

import SwiftUI
import SpriteKit

struct DataLines: View {
    
    @EnvironmentObject var graphData: GraphData
    var xMin: Date?
    var xMax: Date?
    var yMin: CGFloat?
    var yMax: CGFloat?
    var numberOfDaysCovered: CGFloat?
    var paddingX: CGFloat
    var paddingY: CGFloat
    var paddingForLabels: CGFloat
    var colour: Color? = nil
    
    @State private var percentage: CGFloat = .zero
    
    func findMidPoint(pointOne: CGPoint, pointTwo: CGPoint) -> CGPoint {
        return CGPoint(x: (pointOne.x + pointTwo.x)/2, y: (pointOne.y + pointTwo.y)/2)
    }
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                
                guard let yMax = yMax, let yMin = yMin, let xMin = xMin, let xMax = xMax else {
                    return
                }
                
                let yDistance = yMax - yMin
                
                // Function to convert data to CGPoint
                // Adjusts for time period and distance on Y axis (to include negative numbers)
                func dataPointToCGPoint(dataPoint: DataPoint) -> CGPoint {
                    let minsFromStartToDataPoint = Calendar.current.dateComponents([.minute], from: xMin, to: dataPoint.date).minute!
                    let minsFromStartToEnd = Calendar.current.dateComponents([.minute], from: xMin, to: xMax).minute!
                    let unAdjustedPoint = CGPoint(
                        x: CGFloat(minsFromStartToDataPoint) / CGFloat(minsFromStartToEnd) * size.width,
                        y: (dataPoint.value - yMin) / CGFloat(yDistance) * size.height
                    )
                    return adjustCoordinates(unAdjustedPoint)
                }
                
                // Adjusts coordinates for canvas
                // Canvas 0,0 is top left, so invert y axis
                // Create correct padding for labels and data points
                func adjustCoordinates(_ point: CGPoint) -> CGPoint {
                    let invertedY = size.height - point.y
                    return CGPoint(
                        x: (point.x / size.width * (size.width - (2 * paddingX + paddingForLabels))) + paddingX + paddingForLabels,
                        y: (invertedY / size.height * (size.height - (2 * paddingY + paddingForLabels)) + paddingY)
                    )
                }
                
                // Adjusts how strong the curve is
                let curveRatio: CGFloat = 0.01
                
                func convertToControl1(_ pointToConvert: CGPoint, nextPoint: CGPoint) -> CGPoint {
                    // Maintain y axis of prior point, move x axis to right
                    // The distance to adjust the control point by is dependant on the distance between the two data points
                    let adjustmentValue = (nextPoint.x - pointToConvert.x) * curveRatio
                    return (CGPoint(x: pointToConvert.x + adjustmentValue, y: pointToConvert.y))
                }
                
                func convertToControl2(_ pointToConvert: CGPoint, priorPoint: CGPoint) -> CGPoint {
                    // Maintain y axis of current point, move x axis to left
                    // The distance to adjust the control point by is dependant on the distance between the two data points
                    let adjustmentValue = (pointToConvert.x - priorPoint.x) * curveRatio
                    return (CGPoint(x: pointToConvert.x - adjustmentValue, y: pointToConvert.y))
                }
                
                for line in graphData.lines {
                    
                    var gradientColourStart: Color? = line.gradientColourStart
                    var gradientColourFinish: Color? = line.gradientColourFinish
                    
                    if gradientColourStart == nil {
                        gradientColourStart = self.colour
                    }
                    
                    if gradientColourFinish == nil {
                        gradientColourFinish = self.colour
                    }
                    
                    guard let gradientColourStart = gradientColourStart, let gradientColourFinish = gradientColourFinish else {
                        return
                    }

                    
                    // Create path
                    context.stroke(
                        Path { path in
                            
                            guard line.data.count > 0 else {
                                return
                            }
                            
                            path.move(to: dataPointToCGPoint(dataPoint: line.data.first!))
                            
                            for (index, dataPoint) in line.data.enumerated() {
                                if index == 0 {
                                    continue
                                }
                                path.addCurve(
                                    to: dataPointToCGPoint(dataPoint: dataPoint),
                                    control1: convertToControl1(
                                        dataPointToCGPoint(dataPoint: line.data[index-1]),
                                        nextPoint: dataPointToCGPoint(dataPoint: dataPoint)
                                    ),
                                    control2: convertToControl2(
                                        dataPointToCGPoint(dataPoint: dataPoint),
                                        priorPoint: dataPointToCGPoint(dataPoint: line.data[index-1])
                                    ))
                            }
                            
                            
                        },
                        with: .linearGradient(Gradient(colors: [gradientColourStart, gradientColourFinish]), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: size.width, y: 0)),
                        lineWidth: 2)
                    
                }
                
//                if dragPoint != nil {
//                    context.stroke(Path(CGRect(origin: dragPoint!, size: CGSize(width: 1, height: geo.size.height))), with: .color(.orange))
//                    
//                    
//                }
                
            }
        }
    }
}

struct DataLines_Previews: PreviewProvider {
    static func createRelativeDate(_ daysPrior: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -daysPrior, to: Date())!
    }
    @State static var graphData: GraphData = GraphData(lines: [
        LineData(data: [
            DataPoint(date: createRelativeDate(12), value: 12),
            DataPoint(date: createRelativeDate(11), value: 15),
            DataPoint(date: createRelativeDate(8), value: 9),
            DataPoint(date: createRelativeDate(6), value: 10),
            DataPoint(date: createRelativeDate(3), value: 2),
            DataPoint(date: createRelativeDate(1), value: 4),
            DataPoint(date: createRelativeDate(0), value: 3)
        ],
                 gradientColourStart: .red,
                 gradientColourFinish: .blue)
    ])
    static var previews: some View {
        DataLines(
            xMin: createRelativeDate(12),
            xMax: Date(),
            yMin: 5,
            yMax: 21,
            numberOfDaysCovered: 12,
            paddingX: 20,
            paddingY: 20,
            paddingForLabels: 20).frame(width: .infinity, height: 200)
            .environmentObject(graphData)
    }
}
