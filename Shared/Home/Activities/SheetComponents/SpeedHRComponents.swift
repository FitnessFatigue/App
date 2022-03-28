//
//  SpeedTimeComponents.swift
//  FitnessFatigue (iOS)
//
//  Created by Matthew Roche on 24/03/2022.
//

import SwiftUI

struct SpeedHRComponents: View {
    let activity: Activity
    var body: some View {
        if activity.maxSpeed != nil || activity.averageSpeed != nil || activity.maxHeartrate != nil || activity.averageHeartrate != nil {
            VStack {
                HStack {
                    Spacer()
                    if activity.maxSpeed != nil || activity.averageSpeed != nil {
                        VStack {
                            Image(systemName: "speedometer").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
                            Text("Max Speed")
                            if (activity.maxSpeed != nil) {
                                Text("\(String(format: "%.1f", activity.maxSpeed!)) kph")
                            } else {
                                Text("-")
                            }
                            Text("Average Speed")
                            if (activity.averageSpeed != nil) {
                                Text("\(String(format: "%.1f", activity.averageSpeed!)) kph")
                            } else {
                                Text("-")
                            }
                        }
                    }
                    if activity.maxHeartrate != nil || activity.averageHeartrate != nil {
                        Spacer()
                        Spacer()
                        VStack {
                            Image(systemName: "heart.fill").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
                            Text("Max Heartrate")
                            if (activity.maxHeartrate != nil) {
                                Text("\(activity.maxHeartrate!) bpm")
                            } else {
                                Text("-")
                            }
                            Text("Average Heartrate")
                            if (activity.averageHeartrate != nil) {
                                Text("\(activity.averageHeartrate!) bpm")
                            } else {
                                Text("-")
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            if activity.pace != nil {
                HStack {
                    Text("Pace:")
                    Spacer()
                    Text("\(String(format: "%.2f", activity.pace!))/km")
                }
            }
            if activity.gap != nil {
                HStack {
                    Text("GAP:")
                    Spacer()
                    Text("\(String(format: "%.2f", activity.gap!))/km")
                }
            }
            if activity.cadence != nil {
                HStack {
                    Text("Cadence:")
                    Spacer()
                    Text("\(String(format: "%.0f", activity.cadence!))")
                }
            }
            if activity.stride != nil {
                HStack {
                    Text("Stride:")
                    Spacer()
                    Text("\(String(format: "%.2f", activity.stride!))m")
                }
            }
            if activity.maxSpeed != nil || activity.averageSpeed != nil || activity.maxHeartrate != nil || activity.averageHeartrate != nil || activity.pace != nil || activity.gap != nil || activity.cadence != nil || activity.stride != nil {
                Divider()
            }
        }
    }
}
