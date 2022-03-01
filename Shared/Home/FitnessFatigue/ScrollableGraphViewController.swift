//
//  ScrollableGraphViewController.swift
//  Intervals (iOS)
//
//  Created by Matthew Roche on 11/11/2021.
//

import Foundation

import UIKit
import SwiftUI

class GraphViewController : ScrollableGraphViewDataSource {
    
    var fitnessArray: [Double]
    var fatigueArray: [Double]
    var xAxisLabels: [String]
    
    init(fitnessArray: [Double], fatigueArray: [Double], xAxisLabels: [String]) {
        self.fitnessArray = fitnessArray
        self.fatigueArray = fatigueArray
        self.xAxisLabels = xAxisLabels
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        
        switch(plot.identifier) {
                    
        // Data for the graphs with a single plot
        case "fitness":
            return fitnessArray[pointIndex]
        case "fatigue":
            return fatigueArray[pointIndex]
            
        default:
            return 0
        }
        
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return xAxisLabels[pointIndex]
    }
    
    func numberOfPoints() -> Int {
        return fitnessArray.count
    }
    
    var isInDarkMode: Bool {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return true
        }
        else {
            return false
        }
    }
    
    
    func createSimpleGraph(_ frame: CGRect) -> ScrollableGraphView {
            
        // Compose the graph view by creating a graph, then adding any plots
        // and reference lines before adding the graph to the view hierarchy.
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        let fitnessPlot = LinePlot(identifier: "fitness") // Identifier should be unique for each plot.
        fitnessPlot.lineColor = UIColor(Color("LightBlue"))
        fitnessPlot.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        fitnessPlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        fitnessPlot.animationDuration = 1
        let fatiguePlot = LinePlot(identifier: "fatigue")
        fatiguePlot.lineColor = UIColor(Color("Purple"))
        fatiguePlot.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        fatiguePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        fitnessPlot.animationDuration = 1
        
        let referenceLines = ReferenceLines()
        referenceLines.dataPointLabelsSparsity = 5
        referenceLines.referenceLineColor = UIColor.label
        
        
        graphView.addPlot(plot: fitnessPlot)
        graphView.addPlot(plot: fatiguePlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        
        graphView.shouldAdaptRange = true
        graphView.shouldAnimateOnAdapt = true
        graphView.shouldAnimateOnStartup = true
        graphView.direction = ScrollableGraphViewDirection.rightToLeft
        
        graphView.backgroundFillColor = UIColor.systemBackground
        
        return graphView
    }
    
}
    
