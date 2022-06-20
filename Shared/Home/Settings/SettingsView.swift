//
//  SettingsView.swift
//  Intervals
//
//  Created by Matthew Roche on 11/10/2021.
//

import WidgetKit
import SwiftUI
import RealmSwift
import os

// Contains the settings page
struct SettingsView: View {
    
    // The user's profile
    @ObservedObject var userProfile: UserProfile
    // Is the user logged in?
    @Binding var loggedIn: Bool?
    // When did we last sync?
    @Binding var lastSyncDate: Date?
    
    // Is the log out alert visible.
    @State var logOutAlertVisible = false
    @State var redownloadDataInProgress = false
    
    func logOut() {
        // Must set lggedIn to false before deleting realm in order to trigger removal of observers
        loggedIn = false
        
        // Empty Keychain
        KeychainController().removeLoginDetails()
        KeychainController().removeLastSyncDetails()
        
        // Delay Emptying realm to give time for obsrvers to be removed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Empty Realm
            do {
                let realm = try RealmController().returnContainerisedRealm()
                try! realm.write {
                    realm.deleteAll()
                }
            }  catch {
                // If this fails we still wish to continue with log out
            }
            
            // Reload widget
            WidgetCenter.shared.reloadTimelines(ofKind: "intervalsExtension")
        }
    }
    
    func redownloadAllData() {
        Task {
            redownloadDataInProgress = true
            do {
                // Get activities data
                try await DataController().loadActivitiesFromServer(userId: userProfile.id, authToken: userProfile.authToken, allData: true)
                // Get daily values
                try await DataController().loadDailyValuesDataFromServer(userId: userProfile.id, authToken: userProfile.authToken, allData: true)
                
                // Reload widget
                WidgetCenter.shared.reloadTimelines(ofKind: "intervalsExtension")
            } catch {
                os_log("Error during app sync", log: Log.table)
                print(error)
                NotificationCenter.default.post(name: .didCreateError, object: error)
            }
            lastSyncDate = Date()
            redownloadDataInProgress = false
        }
    }
    
    var body: some View {
        List {
            HStack {
                Text("User Id:")
                Spacer()
                Text(userProfile.id)
            }
            HStack {
                Text("User Name:")
                Spacer()
                if userProfile.name != nil {
                    Text("\(userProfile.name!)")
                } else {
                    Text("-")
                }
            }
            HStack {
                Text("Last Sync:")
                Spacer()
                if lastSyncDate != nil {
                    Text("\(lastSyncDate!.formatted(date: .abbreviated, time: .shortened))")
                } else {
                    Text("-")
                }
            }
            
            Toggle(isOn: $userProfile.isPercentageFitness) {
                Text("Form as % of fitness")
            }
            
            Button(action: redownloadAllData) {
                HStack {
                    RotatingSystemImage(systemName: "arrow.clockwise", foregroundColor: .blue, isAnimating: $redownloadDataInProgress)
                    Spacer()
                    Text("Re-download All Data").foregroundColor(.blue)
                }
            }.disabled(redownloadDataInProgress)
            
            Button(action: {logOutAlertVisible = true}) {
                HStack {
                    Spacer()
                    Text("Log Out").foregroundColor(.red)
                    Spacer()
                }
            }
        }.alert(isPresented: $logOutAlertVisible) {
            Alert(
                title: Text("Log Out"),
                message: Text("Are you sure you wish to log out?"),
                primaryButton: .destructive(Text("Log Out"), action: logOut),
                secondaryButton: .cancel()
            )
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    
    @State static var loggedIn: Bool? = true
    @State static var userProfile: UserProfile = UserProfile(id: "kjsdhg", name: "John Doe", email: "john.doe@test.com", sex: "M", dateOfBirth: Calendar.current.date(byAdding: .year, value: -40, to: Date()), authToken: "atesttoken")
    @State static var lastSyncDate: Date? = Date()
    
    static var previews: some View {
        SettingsView(userProfile: userProfile, loggedIn: $loggedIn, lastSyncDate: $lastSyncDate)
    }
}
