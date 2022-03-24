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
        VStack {
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "speedometer").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
                    Text("Max Speed")
                    if (activity.maxSpeed != nil) {
                        Text(activity.maxSpeed!, format: .number)
                    } else {
                        Text("-")
                    }
                    Text("Average Speed")
                    if (activity.averageSpeed != nil) {
                        Text(activity.averageSpeed!, format: .number)
                    } else {
                        Text("-")
                    }
                }
                Spacer()
                Spacer()
                VStack {
                    Image(systemName: "heart.fill").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
                    Text("Max Heartrate")
                    if (activity.maxHeartrate != nil) {
                        Text(activity.maxHeartrate!, format: .number)
                    } else {
                        Text("-")
                    }
                    Text("Average Heartrate")
                    if (activity.averageHeartrate != nil) {
                        Text(activity.averageHeartrate!, format: .number)
                    } else {
                        Text("-")
                    }
                }
                Spacer()
            }
            Divider()
        }
    }
}
