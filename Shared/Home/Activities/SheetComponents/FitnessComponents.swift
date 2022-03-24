//
//  FitnessComponents.swift
//  FitnessFatigue (iOS)
//
//  Created by Matthew Roche on 24/03/2022.
//

import SwiftUI

struct FitnessComponents: View {
    let activity: Activity
    var body: some View {
        VStack {
            if activity.fitness != nil {
                HStack {
                    Text("Fitness:")
                    Spacer()
                    Text(String(format: "%.0f", activity.fitness!))
                }
            }
            if activity.fatigue != nil {
                HStack {
                    Text("Fatigue:")
                    Spacer()
                    Text(String(format: "%.0f", activity.fatigue!))
                }
            }
            if activity.form != nil {
                HStack {
                    Text("Form:")
                    Spacer()
                    Text(String(format: "%.0f", activity.form!))
                }
            }
            Divider()
        }
    }
}
