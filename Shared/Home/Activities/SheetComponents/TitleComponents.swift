//
//  TitleComponents.swift
//  FitnessFatigue (iOS)
//
//  Created by Matthew Roche on 24/03/2022.
//

import SwiftUI

struct TitleComponents: View {
    let activity: Activity
    var body: some View {
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
    }
}
