//
//  IntensityComonents.swift
//  FitnessFatigue (iOS)
//
//  Created by Matthew Roche on 24/03/2022.
//

import SwiftUI

struct IntensityComonents: View {
    let activity: Activity
    var body: some View {
        VStack {
            if (activity.intensity != nil || activity.variability != nil || activity.variability != nil) {
                Image(systemName: "chart.xyaxis.line").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
            }
            if activity.intensity != nil {
                HStack {
                    Text("Intensity:")
                    Spacer()
                    Text("\(String(format: "%.0f", activity.intensity!))%")
                }
            }
            if activity.trainingLoad != nil {
                HStack {
                    Text("Training Load:")
                    Spacer()
                    Text(activity.trainingLoad!, format: .number)
                }
            }
            if activity.variability != nil {
                HStack {
                    Text("Variability:")
                    Spacer()
                    Text(String(format: "%.2f", activity.variability!))
                }
            }
            if activity.efficiency != nil {
                HStack {
                    Text("Efficiency:")
                    Spacer()
                    Text(String(format: "%.2f", activity.efficiency!))
                }
            }
            Divider()
        }
    }
}
