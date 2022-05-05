//
//  LogOutForAccessModal.swift
//  FitnessFatigue (iOS)
//
//  Created by Matthew Roche on 05/05/2022.
//

import SwiftUI
import WidgetKit

struct NeedNewAccessModal: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var userProfile: UserProfile?
    
    var performSync: () -> Void
    
    func performSignIn() {
        
        Task {
            do {
                // Start the request
                let userProfile = try await NetworkController().signIn()
                print(userProfile)
                // Save the profile
                try KeychainController().saveLoginDetails(profile: userProfile)
                self.userProfile = userProfile
                // Reload the widget as we are now logged iin
                WidgetCenter.shared.reloadTimelines(ofKind: "intervalsExtension")
                performSync()
                presentationMode.wrappedValue.dismiss()
            } catch {
                // Handle errors
                print("Caught error in LogInController")
                NotificationCenter.default.post(name: .didCreateError, object: error)
            }
        }
    }
    
    var body: some View {
        VStack {
            
            Text("Need New Access")
                .font(.title)
                .foregroundColor(Color("AccentOrange"))
            
            Spacer()
            
            Image(systemName: "key")
                .font(.system(size: 100))
                .foregroundColor(Color("AccentOrange"))
            
            Spacer()
            
            Text("Following this update to the app we need to request permission to access your wellness data. This is in order to sync the fitness, fatigue and form values with the intervals.icu website, rather than calculating them in the app.")
            
            Spacer()
            
            Text("Please click below to sign in again.").font(.title3)

            Spacer()
            Spacer()

            Button("Sign In", action: performSignIn)
        }
        .padding()
        .interactiveDismissDisabled()
    }
}

struct NeedNewAccessModal_Previews: PreviewProvider {
    
    @State static var userProfile: UserProfile? = UserProfile(id: "234", name: "Joe", email: "Bloggs", sex: "Male", dateOfBirth: Date(), authToken: "abc", scope: nil)
    
    static func performSync() {
        return
    }
    
    static var previews: some View {
        NeedNewAccessModal(userProfile: $userProfile, performSync: performSync)
    }
}
