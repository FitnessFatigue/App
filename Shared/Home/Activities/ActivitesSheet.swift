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
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        ActivityIcon(activityType: activity.type, font:.title)
                        Text(activity.name ?? "-").font(.title).foregroundColor(Color("AccentOrange"))
                        Spacer()
                        VStack {
                            Text(activity.date.formattedDateLongString)
                            Text(activity.type ?? "-").font(.subheadline)
                        }
                    }
                    Divider()
                }
                VStack {
                    Image(systemName: "clock.fill").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
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
                    if activity.calories != nil {
                        HStack {
                            Text("Calories:")
                            Spacer()
                            Text(activity.calories!, format: .number)
                        }
                    }
                    Divider()
                }
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
                VStack {
                    Image(systemName: "bolt.fill").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
                    if activity.averageWatts != nil {
                        HStack {
                            Spacer()
                            VStack {
                                Text("Average Watts: ")
                                Text(activity.averageWatts!, format: .number)
                            }
                            Spacer()
                        }.padding(.bottom)
                    }
                    if activity.estimatedFTP != nil {
                        HStack {
                            Text("Estimated FTP:")
                            Spacer()
                            Text(activity.estimatedFTP!, format: .number)
                        }
                    }
                    if activity.trainingLoad != nil {
                        HStack {
                            Text("Training Load:")
                            Spacer()
                            Text(activity.trainingLoad!, format: .number)
                        }
                    }
                    
                    if (activity.intensity != nil || activity.variability != nil || activity.variability != nil) {
                        Divider()
                        Image(systemName: "chart.xyaxis.line").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
                    }
                    if activity.intensity != nil {
                        HStack {
                            Text("Intensity:")
                            Spacer()
                            Text(activity.intensity!, format: .number)
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
                
                Spacer()
                
                Button {
                    if let url = URL(string: "https://intervals.icu/activities/\(activity.id)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open on Intervals.icu")
                        .foregroundColor(.white)
                }
                .padding()
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
    
    static let activity = Activity(id: 784465, date: Date(), name: "Run", type: "Morning Run", movingTime: 9375, distance: 2355, elapsedTime: 2322, totalElevationGain: 234, maxSpeed: 23, averageSpeed: 20, hasHeartrate: true, maxHeartrate: 78, averageHeartrate: 65, calories: 233, averageWatts: 200, normalisedWatts: 197, intensity: 34, estimatedFTP: 195, variability: 23, efficiency: 23, trainingLoad: 23)
    
    static func closeSheet() {}
    
    static var previews: some View {
        ActivitesSheet(activity: activity, closeSheet: closeSheet)
    }
}
