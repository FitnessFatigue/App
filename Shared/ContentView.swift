//
//  ContentView.swift
//  Shared
//
//  Created by Matthew Roche on 07/10/2021.
//

import SwiftUI
import RealmSwift
import Foundation
import SpriteKit


struct ContentView: View {
    
    // Is the user logged in? Can be nil if we haven't yet determined correct state
    @State private var loggedIn: Bool? = nil
    // The user's current profile
    @State private var userProfile: UserProfile? = nil
    // The error being displayed. Nil if none displayed
    @State private var displayedError: AppError? = nil
    
    // A queue of errors
    var errorQueue = ErrorQueue()
    
    var body: some View {
        NavigationView {
            
            VStack {
                
                // Handling correct page for log in status
                if loggedIn == nil {
                    LoadingView()
                } else if loggedIn! {
                    Home(userProfile: $userProfile, loggedIn: $loggedIn)
                } else {
                    LogInController(loggedIn: $loggedIn, userProfile: $userProfile)
                }
                
                // Set up and error handling
                Text("")
                .hidden()
                .onAppear(perform: {
                    self.setUp()
                })
                .alert(item: $displayedError) { error in
                    Alert(
                        title: Text("Error"),
                        message: Text(error.localizedDescription),
                        dismissButton: Alert.Button.cancel({
                            self.displayedError = self.errorQueue.next()
                        })
                    )
                }
                
            } // VStack
        } // NavigationView
    } // View
    
    func setUp() -> Void {
        
        setUpRealm()
        
        setUpErrorHandling()
        
        handleLogInStatus()
    }
    
    func setUpRealm() -> Void {
        // Set up Realm versioning
        RealmController().setUp()
        
        var realm: Realm? = nil
        
        // Check we can load Realm
        do {
            realm = try RealmController().returnContainerisedRealm()
            print("User Realm User file location: \(realm!.configuration.fileURL!.path)")
        } catch {
            print("Unable to load realm")
            NotificationCenter.default.post(name: .didCreateError, object: error)
        }
    }
    
    func setUpErrorHandling() -> Void {
        NotificationCenter.default.addObserver(forName: .didCreateError, object: nil, queue: nil) { notification in
            guard let error = notification.object as? Error else {
                return
            }
            errorQueue.append(error)
            if displayedError == nil {
                displayedError = errorQueue.next()
            }
        }
    }
    
    func handleLogInStatus() -> Void {
        guard let userProfile = try? KeychainController().getLoginDetails() else {
            print("No stored login details")
            loggedIn = false
            return
        }
        
        self.userProfile = userProfile

        loggedIn = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
