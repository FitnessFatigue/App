//
//  LogInView.swift
//  Intervals (iOS)
//
//  Created by Matthew Roche on 14/10/2021.
//

import SwiftUI

// Contains the UI for logging in
struct LogInView: View {
    
    // Is the a log in in progress?
    @Binding var logInProcessing: Bool
    
    // Function from controller
    var logIn: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Image("LargeIcon")
                .resizable()
                .scaledToFit()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .padding()
            Spacer()
            Text("Press the Log In button to go to the Intervals.icu website and log in securely.")
                .multilineTextAlignment(.center)
                .padding(.bottom)
            Button(action: {logIn()}) {
                HStack {
                    Spacer()
                    Text("Log In")
                        .foregroundColor(Color.white).padding()
                    if logInProcessing {
                        RotatingSystemImage(
                            systemName: "arrow.triangle.2.circlepath",
                            foregroundColor: .white,
                            isAnimating: $logInProcessing
                        ).padding()
                    }
                    Spacer()
                }.background(Color("AccentOrange")).cornerRadius(10).padding()
            }
        }
        .padding()
        .navigationTitle("Log In")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // Change the title text colour
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color("AccentOrange"))]
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    @State static var logInProcessing: Bool = false
    static func logIn() -> Void {}
    static var previews: some View {
        LogInView(logInProcessing: $logInProcessing, logIn: logIn)
    }
}
