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
                .frame(minWidth: UIScreen.main.bounds.size.width * 2/3)
                .padding()
                .foregroundColor(.white)
                .background(Color(red: 204/255, green: 56/255, blue: 75/255))
                .clipShape(Capsule())
                
                if activity.source == "STRAVA" {
                    Button("Open on Strava") {
                        if let url = URL(string: "https://www.strava.com/activities/\(activity.id)") {
                            print(url)
                            UIApplication.shared.open(url)
                        }
                    }
                    .frame(minWidth: UIScreen.main.bounds.size.width * 2/3)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(red: 233/255, green: 95/255, blue: 42/255))
                    .clipShape(Capsule())
                }

                
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done", action: closeSheet).foregroundColor(Color("AccentOrange")))
        }
    }
}

struct ActivitesSheet_Previews: PreviewProvider {
    
    static let cycleActivity = Activity(id: "784465", date: Date(), name: "Cycle", type: "Morning Cycle", movingTime: 9375, distance: 2355, elapsedTime: 2322, totalElevationGain: 234, maxSpeed: 23.676, averageSpeed: 20.7676, hasHeartrate: true, maxHeartrate: 78, averageHeartrate: 65, calories: 233, averageWatts: 200, normalizedWatts: 197, intensity: 34.78676, estimatedFTP: 195, variability: 23, efficiency: 23, trainingLoad: 23, fitness: 32, fatigue: 10, form: 22, workOverFTP: 46, FTP: 228, rideFTP: 177, work: 234, cadence: 223.23425, source: "STRAVA")
    
    static let runAactivity = Activity(id: "784465", date: Date(), name: "Run", type: "Morning Run", movingTime: 9375, distance: 255, elapsedTime: 2322, totalElevationGain: 24, maxSpeed: 3.676, averageSpeed: 2.7676, hasHeartrate: true, maxHeartrate: 78, averageHeartrate: 65, calories: 233, intensity: 13.78676, trainingLoad: 23, fitness: 32, fatigue: 10, form: 22, pace: 2.23523, gap: 3.3252, stride: 2.234234, source: "STRAVA")
    
    static func closeSheet() {}
    
    static var previews: some View {
        Group {
            ActivitesSheet(activity: cycleActivity, closeSheet: closeSheet)
            ActivitesSheet(activity: runAactivity, closeSheet: closeSheet)
        }
    }
}
