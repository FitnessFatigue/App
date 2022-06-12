//
//  TabHolder.swift
//  DarkMaps (iOS)
//
//  Created by Matthew Roche on 30/01/2021.
//

import SwiftUI
import RealmSwift
import WidgetKit
import os

// Defines the tab content and its position on the screen
struct TabHolder: View {
    
    // The user's profile
    @Binding var userProfile: UserProfile
    // Is the user logged in? Required to allow the user to log out
    @Binding var loggedIn: Bool?
    // Which tab is active?
    @Binding var selectedTab: TabOptions
    // Is a sync in progress?
    @Binding var isSyncing: Bool
    // When did we last perform a sync?
    @Binding var lastSyncDate: Date?
    
    // Calculating the position of the tabs.
    // All tabs are created, but are moved on the X-Axis to animate into / out of view
    var calculatedFitnessFatigueX: CGFloat {
        let width = UIScreen.main.bounds.size.width
        switch selectedTab {
        case .fitnessFatigue:
            return 0
        default:
            return -width
        }
    }
    
    // Calculating the position of the tabs.
    // All tabs are created, but are moved on the X-Axis to animate into / out of view
    var calculatedActivitiesX: CGFloat {
        let width = UIScreen.main.bounds.size.width
        switch selectedTab {
        case .fitnessFatigue:
            return width
        case .activities:
            return 0
        case .settings:
            return -width
        }
    }
    
    // Calculating the position of the tabs.
    // All tabs are created, but are moved on the X-Axis to animate into / out of view
    var calculatedSettingsX: CGFloat {
        let width = UIScreen.main.bounds.size.width
        switch selectedTab {
        case .settings:
            return 0
        default:
            return width
        }
    }
    
    var body: some View {
        
        ZStack {
            FitnessFatigueController(userProfile: userProfile)
                .offset(x: calculatedFitnessFatigueX)
            ActivitiesController()
                .offset(x: calculatedActivitiesX)
            SettingsView(
                userProfile: userProfile,
                loggedIn: $loggedIn,
                lastSyncDate: $lastSyncDate)
                .offset(x: calculatedSettingsX)
        }
        
    }
}
