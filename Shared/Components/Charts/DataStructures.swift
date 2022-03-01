//
//  DataStructures.swift
//  SwiftUIChartsPlayground
//
//  Created by Matthew Roche on 25/11/2021.
//

import Foundation
import SwiftUI

struct DataPoint: Equatable {
    var date: Date
    var value: CGFloat
    
    static func == (lhs: DataPoint, rhs: DataPoint) -> Bool {
        lhs.date == rhs.date && lhs.value == rhs.value
    }
}

struct LineData: Identifiable, Equatable {
    
    var id = UUID()
    var label: String?
    var data: [DataPoint]
    var gradientColourStart: Color? = nil
    var gradientColourFinish: Color? = nil
    
    init(label: String? = nil, data: [DataPoint], gradientColourStart: Color? = nil, gradientColourFinish: Color? = nil) {
        self.label = label
        self.data = data
        self.gradientColourStart = gradientColourStart ?? nil
        self.gradientColourFinish = gradientColourFinish ?? nil
    }
    
    static func == (lhs: LineData, rhs: LineData) -> Bool {
        lhs.id == rhs.id
    }
}

class GraphData: Equatable, ObservableObject {
    var title: String?
    var lines: [LineData] {
        willSet {
            objectWillChange.send()
        }
    }
    
    init(title: String? = nil, lines: [LineData]) {
        self.title = title
        self.lines = lines
    }
    
    static func == (lhs: GraphData, rhs: GraphData) -> Bool {
        lhs.lines == rhs.lines
    }
}
