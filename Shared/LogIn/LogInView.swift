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
    
    // Storing the data from the text boxes
    @State var usernameText: String = ""
    @State var passwordText: String = ""
    
    // Function from controller
    var logIn: (String, String) -> Void
    
    var body: some View {
        VStack {
            Image("LargeIcon")
                .resizable()
                .scaledToFit()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .padding()
            Spacer()
            TextField("User Name", text: $usernameText)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .padding(.bottom, 40)
            SecureField("Password", text: $passwordText)
                .textFieldStyle(.roundedBorder)
            Spacer()
            Button(action: {logIn(usernameText, passwordText)}) {
                HStack {
                    Text("Log In")
                        .foregroundColor(Color.white).padding()
                    if logInProcessing {
                        RotatingSystemImage(
                            systemName: "arrow.triangle.2.circlepath",
                            foregroundColor: .white,
                            isAnimating: $logInProcessing
                        ).padding()
                    }
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
    static func logIn(username: String, password: String) -> Void {}
    static var previews: some View {
        LogInView(logInProcessing: $logInProcessing, logIn: logIn)
    }
}
