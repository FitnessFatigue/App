//
//  AcivityIcon.swift
//  FitnessFatigue (iOS)
//
//  Created by Matthew Roche on 24/03/2022.
//

import SwiftUI

struct ActivityIcon: View {
    let activityType: String
    let font: Font
    
    init(activityType: String?, font: Font = .body) {
        self.activityType = activityType ?? ""
        self.font = font
    }
    
    var body: some View {
        Image(systemName: activityType == "Run" ? "figure.walk" :
                activityType == "Ride" ? "bicycle" :
                activityType == "VirtualRide" ? "bicycle.circle" : "heart")
            .foregroundColor(Color("AccentOrange"))
            .font(font)
    }
}

//struct AcivityIcon_Previews: PreviewProvider {
//    static var previews: some View {
//        AcivityIcon()
//    }
//}
