//
//  LogInController.swift
//  Intervals (iOS)
//
//  Created by Matthew Roche on 14/10/2021.
//

import WidgetKit
import SwiftUI

// Controller for the log in view
struct LogInController: View {
    
    // Is the user logged in
    @Binding var loggedIn: Bool?
    // What is the user's profile
    @Binding var userProfile: UserProfile?
    
    // Is a login in progress?
    @State var logInProcessing: Bool = false
    
    // Handles actually logging the user in
    func logIn(email: String, password: String) {
        
        // Start displaying the processing UI
        logInProcessing = true
        
        // Handle the network request
        Task {
            do {
                // Start the request
                let userProfile = try await NetworkController().logIn(email: email, password: password)
                // Save the profile
                try KeychainController().saveLoginDetails(profile: userProfile)
                self.userProfile = userProfile
                // Reload the widget as we are now logged iin
                WidgetCenter.shared.reloadTimelines(ofKind: "intervalsExtension")
                // Remove the logging in UI
                logInProcessing = false
                // We are now logged in
                loggedIn = true
            } catch {
                // Handle errors
                logInProcessing = false
                print("Caught error in LogInController")
                NotificationCenter.default.post(name: .didCreateError, object: error)
            }
        }
    }
    
    var body: some View {
        LogInView(logInProcessing: $logInProcessing, logIn: logIn)
    }
}

struct LogInController_Previews: PreviewProvider {
    @State static var loggedIn: Bool? = false
    @State static var userProfile: UserProfile? = nil
    static var previews: some View {
        LogInController(loggedIn: $loggedIn, userProfile: $userProfile)
    }
}
