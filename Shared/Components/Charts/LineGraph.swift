//
//  LineGraph.swift
//  SwiftUIChartsPlayground
//
//  Created by Matthew Roche on 25/11/2021.
//

import SwiftUI

struct LineGraph: View {
    
    // TODO
    // Fix colour bucket borders
    // Fix graph repained with drag
    
    @EnvironmentObject var graphData: GraphData
    @Binding var dragPoint: CGPoint?
    @Binding var dragPointDay: Int?
    @Binding var dragPointDate: Date?
    
    var colourBuckets: [(CGFloat, Color)]? = nil
    var minGraphLabels: [CGFloat]? = nil
    var fixedGraphLabels: [CGFloat]? = nil
    var yAxisLabels: Bool = true
    
    @State var xMin: Date = Date(timeIntervalSince1970: -(60*60*24))
    @State var xMax: Date = Date()
    @State var yMin: CGFloat = 0
    @State var yMax: CGFloat = 1
    @State var numberOfDaysCovered: CGFloat = 1
    
    let paddingForLabels: CGFloat = 20
    let paddingX: CGFloat = 20
    let paddingY: CGFloat = 10
    let desiredLineHeights: [CGFloat] = [0, 1/3, 2/3, 1]
    
    var yDistance: CGFloat {
        return yMax - yMin
    }
    
    func calculateMaxAndMin() {
        var foundXMin: Date? = nil
        var foundXMax: Date? = nil
        var foundYMin: CGFloat? = nil
        var foundYMax: CGFloat? = nil
        
        for line in $graphData.lines {
            if line.data.count > 0 {
                if foundXMin == nil {
                    foundXMin = line.data.first!.date.wrappedValue
                } else {
                    if line.data.first!.date.wrappedValue < foundXMin! {
                        foundXMin = line.data.first!.date.wrappedValue
                    }
                }
            } else {
                foundXMin = Date()
            }
            
            if line.data.count > 0 {
                if foundXMax == nil {
                    foundXMax = line.data.last!.date.wrappedValue
                } else {
                    if line.data.last!.date.wrappedValue > foundXMax! {
                        foundXMax = line.data.last!.date.wrappedValue
                    }
                }
            } else {
                foundXMax = Date()
            }
            
            if line.data.count > 0 {
                let yMinForThisLine = line.data.wrappedValue.map({ x in x.value }).min()!
                if foundYMin == nil {
                    foundYMin = yMinForThisLine
                } else {
                    if yMinForThisLine < foundYMin! {
                        foundYMin = yMinForThisLine
                    }
                }
            } else {
                foundYMin = 0
            }
            
            if line.data.count > 0 {
                let yMaxForThisLine = line.data.wrappedValue.map({ x in x.value }).max()!
                if foundYMax == nil {
                    foundYMax = yMaxForThisLine
                } else {
                    if yMaxForThisLine > foundYMax! {
                        foundYMax = yMaxForThisLine
                    }
                }
            } else {
                foundYMax = 0
            }
        }
        guard let foundXMin = foundXMin, let foundXMax = foundXMax, let foundYMin = foundYMin, let foundYMax = foundYMax else {
            print("Calculated nil")
            return
        }
        
        xMin = foundXMin
        xMax = foundXMax
        
        if minGraphLabels != nil {
            yMin = min(minGraphLabels!.min()!, foundYMin)
            yMax = max(minGraphLabels!.max()!, foundYMax)
        } else {
            yMin = foundYMin
            yMax = foundYMax
        }
        
        numberOfDaysCovered = CGFloat(Calendar.current.dateComponents([.day], from: xMin, to: xMax).day!)
    }
    
    func calculateBucketHeight(bucketBorder: CGFloat, frameHeight: CGFloat) -> CGFloat {
        let borderAsProportionOfRange = (bucketBorder - yMin) / yDistance

        let invertedBorderAsProportionOfRange = 1 - borderAsProportionOfRange

        let graphHeight = graphHeight(totalHeight: frameHeight) - (2 * paddingY + paddingForLabels)

        return (invertedBorderAsProportionOfRange * graphHeight) + paddingY
    }
    
    func graphHeight(totalHeight: CGFloat) -> CGFloat {
        if graphData.title != nil {
            return totalHeight - 70
        } else {
            return totalHeight - 50
        }
    }
    
    var actualLabelValues: [CGFloat] {
        if fixedGraphLabels != nil {
            return fixedGraphLabels!
        }
        var actualLabelValues: [CGFloat] = []
        for desiredLineHeight in desiredLineHeights {
            actualLabelValues.append(CGFloat(Int(yMin + yDistance * desiredLineHeight)))
        }
        return actualLabelValues
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                if graphData.title != nil {
                    HStack {
                        Text(graphData.title!).font(.title3).padding(.leading, paddingX)
                        Spacer()
                    }.frame(height: 30)
                }
                if (colourBuckets == nil) {
                    HStack {
                        ForEach(graphData.lines) { line in
                            if line.label != nil {
                                if line.gradientColourStart != nil && line.gradientColourFinish != nil {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [line.gradientColourStart!, line.gradientColourFinish!]),
                                            startPoint: .leading,
                                            endPoint: .trailing))
                                        .frame(width: 15, height: 15)
                                    Text(line.label!).padding(.trailing)
                                }
                            }
                        }
                        Spacer()
                    }.padding(.leading, paddingX).frame(height: 20)
                }
                ZStack {
                        
                    GraphLabels(xMin: $xMin, xMax: $xMax, yMin: $yMin, yMax: $yMax, paddingX: paddingX, paddingY: paddingY, paddingForLabels: paddingForLabels, lineLabels: actualLabelValues, yAxisLabels: yAxisLabels)
                    
                    
                    GraphLines(yMin: $yMin, yMax: $yMax, paddingX: paddingX, paddingY: paddingY, paddingForLabels: paddingForLabels, lineLabels: actualLabelValues)
                    
                    if colourBuckets == nil {
                        // Data lines and points
                        DataLines(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, numberOfDaysCovered: numberOfDaysCovered, paddingX: paddingX, paddingY: paddingY, paddingForLabels: paddingForLabels)
                            .environmentObject(graphData)
                    } else {
                        ForEach(Array(colourBuckets!.enumerated()), id: \.offset) {index, colourBucket in
                            DataLines(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, numberOfDaysCovered: numberOfDaysCovered, paddingX: paddingX, paddingY: paddingY, paddingForLabels: paddingForLabels, colour: colourBucket.1)
                                .environmentObject(graphData)
                                .clipShape(Rectangle().size(CGSize(
                                    width: geo.size.width,
                                    height: index == 0 ? geo.size.height : calculateBucketHeight(
                                        bucketBorder: colourBucket.0,
                                        frameHeight: geo.size.height)
                                )))
                        }
                    }
                    
                    DragLine(dragPoint: dragPoint)
                }
                .frame(width: geo.size.width, height: graphHeight(totalHeight: geo.size.height))
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ touch in
                        if touch.location.x > paddingX + paddingForLabels && touch.location.x < geo.size.width - paddingX {
                            dragPoint = CGPoint(
                                x: touch.location.x,
                                y: 0
                            )
                            let widthOfOneDay = (geo.size.width - paddingX - paddingForLabels) / CGFloat(numberOfDaysCovered)
                            // Calculate which day we are in
                            let calculatedTouchLocation = touch.location.x - paddingX - paddingForLabels + widthOfOneDay / 2
                            let calculatedGraphWidth = geo.size.width - 2 * paddingX - paddingForLabels
                            let currentDay = Int(
                                calculatedTouchLocation / calculatedGraphWidth * numberOfDaysCovered)
                            dragPointDay = currentDay
                            let currentDate = Calendar.current.date(byAdding: .day, value: currentDay, to: xMin)
                            dragPointDate = currentDate
                        }
                    })
                    .onEnded({ touch in
                        dragPoint = nil
                        dragPointDate = nil
                        dragPointDay = nil
                    })
                )
            }
        }.onReceive(graphData.objectWillChange) { _ in
            calculateMaxAndMin()
        }.onAppear() {
            if self.$graphData.lines.count > 0 &&
                self.$graphData.lines.first!.data.count > 0 {
                calculateMaxAndMin()
            }
        }
    }
}

struct LineGraph_Previews: PreviewProvider {
    @State static var graphData = GraphData(
        title: "A test graph",
        lines: [
            LineData(
                label: "A test line",
                data: [
                    DataPoint(date: produceRelativeDate(15), value: 1),
                    DataPoint(date: produceRelativeDate(14), value: 4),
                    DataPoint(date: produceRelativeDate(10), value: 1),
                    DataPoint(date: produceRelativeDate(9), value: 1),
                    DataPoint(date: produceRelativeDate(8), value: 1),
                    DataPoint(date: produceRelativeDate(3), value: 1),
                    DataPoint(date: produceRelativeDate(1), value: 1),
                    DataPoint(date: produceRelativeDate(0), value: 1)
                ], gradientColourStart: .red, gradientColourFinish: .blue)
    ])
    @State static var graphDataBucketed = GraphData(
        title: "A test graph",
        lines: [
            LineData(
                label: "A test line",
                data: [
                    DataPoint(date: produceRelativeDate(15), value: -40),
                    DataPoint(date: produceRelativeDate(14), value: -30),
                    DataPoint(date: produceRelativeDate(10), value: -10),
                    DataPoint(date: produceRelativeDate(9), value: 5),
                    DataPoint(date: produceRelativeDate(8), value: 20),
                    DataPoint(date: produceRelativeDate(3), value: 30),
                    DataPoint(date: produceRelativeDate(2), value: 50),
                    DataPoint(date: produceRelativeDate(1), value: 60)
                ])
    ])
    @State static var dragPoint: CGPoint? = nil
    @State static var dragPointDay: Int? = nil
    @State static var dragPointDate: Date? = nil
    static var previews: some View {
        Group {
            LineGraph(dragPoint: $dragPoint, dragPointDay: $dragPointDay, dragPointDate: $dragPointDate)
                .environmentObject(graphData)
            LineGraph(dragPoint: $dragPoint, dragPointDay: $dragPointDay, dragPointDate: $dragPointDate, colourBuckets: [(-2, .red), (9, .green)])
                .environmentObject(graphData)
            LineGraph(
                dragPoint: $dragPoint,
                dragPointDay: $dragPointDay,
                dragPointDate: $dragPointDate,
                colourBuckets: [(0, .red), (-30, .green), (-10, .gray), (5, .blue), (20, .yellow)],
                minGraphLabels: [-40, -30, -10, 5, 40]
            ) .environmentObject(graphDataBucketed)
        }
    }
}

enum LineGraphError: Error {
    case unableToCalculateMinMax
}

func produceRelativeDate(_ daysPrevious: Int) -> Date {
    return Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -daysPrevious, to: Date())!)
}

