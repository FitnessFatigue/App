//
//  SettingsView.swift
//  Intervals
//
//  Created by Matthew Roche on 11/10/2021.
//

import WidgetKit
import SwiftUI
import RealmSwift

// Contains the settings page
struct SettingsView: View {
    
    // The user's profile
    @Binding var userProfile: UserProfile?
    // Is the user logged in?
    @Binding var loggedIn: Bool?
    // When did we last sync?
    @Binding var lastSyncDate: Date?
    
    // Is the log out alert visible.
    @State var logOutAlertVisible = false
    
    func logOut() {
        // Must set lggedIn to false before deleting realm in order to trigger removal of observers
        loggedIn = false
        
        // Empty Keychain
        KeychainController().removeLoginDetails()
        KeychainController().removeLastSyncDetails()
        
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
    
    var body: some View {
        List {
            HStack {
                Text("User Id:")
                Spacer()
                if userProfile != nil {
                    Text(userProfile!.id)
                } else {
                    Text("-")
                }
            }
            HStack {
                Text("User Name:")
                Spacer()
                if userProfile != nil && userProfile?.firstName != nil && userProfile?.lastName != nil {
                    Text("\(userProfile!.firstName!) \(userProfile!.lastName!)")
                } else {
                    Text("-")
                }
            }
            HStack {
                Text("Email:")
                Spacer()
                if userProfile != nil && userProfile?.email != nil {
                    Text(userProfile!.email!)
                } else {
                    Text("-")
                }
            }
            HStack {
                Text("Sex:")
                Spacer()
                if userProfile != nil && userProfile?.sex != nil {
                    if userProfile!.sex! == "M" {
                        Text("Male")
                    } else if userProfile!.sex! == "F" {
                        Text("Female")
                    } else {
                        Text("-")
                    }
                } else {
                    Text("-")
                }
            }
            HStack {
                Text("DOB:")
                Spacer()
                if userProfile != nil && userProfile?.dateOfBirth != nil {
                    Text(userProfile!.dateOfBirth!.formattedDateLongString)
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
    @State static var userProfile: UserProfile? = UserProfile(id: "kjsdhg", firstName: "John", lastName: "Doe", email: "john.doe@test.com", sex: "M", dateOfBirth: Calendar.current.date(byAdding: .year, value: -40, to: Date()), authToken: "atesttoken")
    @State static var lastSyncDate: Date? = Date()
    
    static var previews: some View {
        SettingsView(userProfile: $userProfile, loggedIn: $loggedIn, lastSyncDate: $lastSyncDate)
    }
}
