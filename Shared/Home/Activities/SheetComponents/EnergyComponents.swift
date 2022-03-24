//
//  EnergyComponents.swift
//  FitnessFatigue (iOS)
//
//  Created by Matthew Roche on 24/03/2022.
//

import SwiftUI

struct EnergyComponents: View {
    let activity: Activity
    var body: some View {
        Image(systemName: "bolt").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
        
        if activity.calories != nil {
            HStack {
                Text("Calories:")
                Spacer()
                Text(activity.calories!, format: .number)
            }
        }
        if activity.work != nil {
            HStack {
                Text("Work:")
                Spacer()
                Text(activity.work!, format: .number)
            }
        }
        if activity.workOverFTP != nil {
            HStack {
                Text("Work Over FTP:")
                Spacer()
                Text(activity.workOverFTP!, format: .number)
            }
        }
        Divider()
    }
}

