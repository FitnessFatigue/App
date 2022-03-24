//
//  WattsFTPComponents.swift
//  FitnessFatigue (iOS)
//
//  Created by Matthew Roche on 24/03/2022.
//

import SwiftUI

struct WattsFTPComponents: View {
    let activity: Activity
    var body: some View {
        VStack {
            Image(systemName: "bolt.fill").padding(.leastNormalMagnitude).font(.title).foregroundColor(Color("AccentOrange"))
            if activity.averageWatts != nil {
                HStack {
                    Spacer()
                    VStack {
                        Text("Average Watts: ")
                        Text(activity.averageWatts!, format: .number)
                        if activity.normalizedWatts != nil {
                            Text("Normalized Watts: ")
                            Text(activity.normalizedWatts!, format: .number)
                        }
                    }
                    Spacer()
                }.padding(.bottom)
            }
            if activity.FTP != nil {
                HStack {
                    Text("FTP:")
                    Spacer()
                    Text(activity.FTP!, format: .number)
                }
            }
            if activity.estimatedFTP != nil {
                HStack {
                    Text("Estimated FTP:")
                    Spacer()
                    Text(activity.estimatedFTP!, format: .number)
                }
            }
            if activity.rideEFTP != nil {
                HStack {
                    Text("Ride Estimated FTP:")
                    Spacer()
                    Text(activity.rideEFTP!, format: .number)
                }
            }
            Divider()
        }
    }
}
