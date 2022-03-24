//
//  TimeComponents.swift
//  FitnessFatigue (iOS)
//
//  Created by Matthew Roche on 24/03/2022.
//

import SwiftUI

struct TimeComponents: View {
    
    let activity: Activity
    
    // Produce a string from a time interval
    func formatTimeInterval(interval: Int?) -> String {
        guard let interval = interval else {
            return "-"
        }
        let intervalDouble = Double(interval)
        let timeInterval = TimeInterval(intervalDouble)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: timeInterval) ?? "-"
    }
    
    var body: some View {
        VStack {
            Image(systemName: "clock.fill").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
            if activity.distance != nil {
                HStack {
                    Text("Distance:")
                    Spacer()
                    Text(activity.formattedDistance)
                }
            }
            HStack {
                Text("Moving Time:")
                Spacer()
                Text(formatTimeInterval(interval: activity.movingTime))
            }
            HStack {
                Text("Elapsed Time:")
                Spacer()
                Text(formatTimeInterval(interval: activity.elapsedTime))
            }
            if activity.totalElevationGain != nil {
                HStack {
                    Text("Elevation Gain:")
                    Spacer()
                    Text(activity.totalElevationGain!, format: .number)
                    Text("m")
                }
            }
            
            Divider()
            
        }
    }
}

