//
//  Home.swift
//  Intervals (iOS)
//
//  Created by Matthew Roche on 23/11/2021.
//

import SwiftUI
import os
import WidgetKit

// The root view for the logged in state
struct Home: View {
    
    // The user's profile
    @Binding var userProfile: UserProfile?
    // Is the user logged in? Required to allow the user to log out
    @Binding var loggedIn: Bool?
    
    // Which tab is active?
    @State var selectedTab: TabOptions = .fitnessFatigue
    // Is a sync in progress?
    @State var isSyncing: Bool = false
    // When did we last perform a sync?
    @State var lastSyncDate: Date? = nil
    
    // Handle syncing with the server
    func performSync() {
        
        os_log("Starting app sync", log: Log.table)
        
        // If a sync is already in progress don't start a new one
        if isSyncing {
            return
        }
        
        // Get the user profile for authentication
        guard let userProfile = userProfile else {
            // Stop animation
            os_log("Stopped app sync as no user profile available", log: Log.table)
            isSyncing = false
            return
        }
        
        Task {
            do {
                
                // Start UI changes and lock syncing
                isSyncing = true
                
                // Get activities data
                try await DataController().loadActivitiesFromServer(userId: userProfile.id, authToken: userProfile.authToken)
                // Get daily values
                try await DataController().loadDailyValuesDataFromServer(userId: userProfile.id, authToken: userProfile.authToken)
                
                // Stop animation and remove sync lock
                isSyncing = false
                
                // Reload widget
                WidgetCenter.shared.reloadTimelines(ofKind: "intervalsExtension")
                
                // Store sync date
                KeychainController().saveLastSyncDetails(date: Date())
                lastSyncDate = Date()
                
                os_log("Finished app sync", log: Log.table)
            } catch {
                os_log("Error during app sync", log: Log.table)
                print(error)
                isSyncing = false
                NotificationCenter.default.post(name: .didCreateError, object: error)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            
            // The tab pages
            TabHolder(
                userProfile: $userProfile,
                loggedIn: $loggedIn,
                selectedTab: $selectedTab,
                isSyncing: $isSyncing,
                lastSyncDate: $lastSyncDate)
            
            Divider()
            
            // The tab bar
            TabBar(selectedTab: $selectedTab)
            
        }
        // Dynamic title change depending on selected tab
        .navigationTitle(selectedTab.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing:
                // Sync button
                Button {
                    performSync()
                } label: {
                    RotatingSystemImage(systemName: "arrow.clockwise", isAnimating: $isSyncing)
                }
        )
        .onAppear {
            // On logging in
            //  - Get the last sync date
            //  - Perform a new sync
            self.lastSyncDate = try? KeychainController().getLastSyncDetails()
            performSync()
        }
        // Update sync date on entering foreground as syncs may have come from widget
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            lastSyncDate = try? KeychainController().getLastSyncDetails()
        }
    }
}


// Define the tabs and their titles
enum TabOptions {
    case fitnessFatigue, activities, settings
    
    var title : String {
        switch self {
        case .fitnessFatigue: return "Fitness and Fatigue"
        case .activities: return "Activities"
        case .settings: return "Settings"
        }
      }
}
