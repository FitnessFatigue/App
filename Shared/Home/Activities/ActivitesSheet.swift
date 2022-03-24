//
//  ActivitesSheet.swift
//  Intervals
//
//  Created by Matthew Roche on 06/11/2021.
//

import SwiftUI

// The sheet displaying detailed information about the selected activity
struct ActivitesSheet: View {
    
    // The activity to display
    var activity: Activity
    // Allows the sheet to be closed
    var closeSheet: () -> Void
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                TitleComponents(activity: activity)
                TimeComponents(activity: activity)
                SpeedHRComponents(activity: activity)
                WattsFTPComponents(activity: activity)
                IntensityComonents(activity: activity)
                EnergyComponents(activity: activity)
                FitnessComponents(activity: activity)
                
                
                Button("Open on Intervals.icu") {
                    if let url = URL(string: "https://intervals.icu/activities/\(activity.id)") {
                        UIApplication.shared.open(url)
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color(red: 204/255, green: 56/255, blue: 75/255))
                .clipShape(Capsule())

                
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done", action: closeSheet).foregroundColor(Color("AccentOrange")))
        }
    }
}

struct ActivitesSheet_Previews: PreviewProvider {
    
    static let activity = Activity(id: 784465, date: Date(), name: "Run", type: "Morning Run", movingTime: 9375, distance: 2355, elapsedTime: 2322, totalElevationGain: 234, maxSpeed: 23, averageSpeed: 20, hasHeartrate: true, maxHeartrate: 78, averageHeartrate: 65, calories: 233, averageWatts: 200, normalizedWatts: 197, intensity: 34, estimatedFTP: 195, variability: 23, efficiency: 23, trainingLoad: 23, fitness: 32, fatigue: 10, form: 22, workOverFTP: 46, FTP: 228, rideFTP: 177, work: 234)
    
    static func closeSheet() {}
    
    static var previews: some View {
        ActivitesSheet(activity: activity, closeSheet: closeSheet)
    }
}
