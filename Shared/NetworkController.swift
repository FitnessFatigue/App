//
//  NetworkController.swift
//  Intervals
//
//  Created by Matthew Roche on 20/10/2021.
//

import Foundation
import AuthenticationServices

// Handles network operations
class NetworkController: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    func signIn() async throws -> UserProfile {
        
        guard let signInURL = URL(string: "https://intervals.icu/oauth/authorize?client_id=12&redirect_uri=https://api.fitness-fatigue.com/intervalsOauthHandler&scope=ACTIVITY") else {
            throw NetworkControllerError.ErrorLoggingIn
        }
        
        let task = Task { ()-> UserProfile in
            
            return try await withCheckedThrowingContinuation { continuation in
            
                let authenticationSession = ASWebAuthenticationSession(
                    url: signInURL,
                    callbackURLScheme: "intervalsapp") { url, error in
                        guard error == nil, let successURL = url else {
                            print(error!)
                            print("Nothing")
                            continuation.resume(throwing: NetworkControllerError.ErrorLoggingIn)
                            return
                        }
                        
                        print(successURL)
                        
                        guard let urlComponents = URLComponents(url: successURL, resolvingAgainstBaseURL: false),
                              let queryItems = urlComponents.queryItems else {
                            continuation.resume(throwing: NetworkControllerError.ErrorLoggingIn)
                            return
                        }
                        
                        guard let tokenType = queryItems.first(where: { $0.name == "token_type" })?.value else {
                            continuation.resume(throwing: NetworkControllerError.ErrorLoggingIn)
                            return
                            
                        }
                        guard let accessToken = queryItems.first(where: { $0.name == "access_token" })?.value,
                                let scope = queryItems.first(where: { $0.name == "scope" })?.value,
                                let athleteId = queryItems.first(where: { $0.name == "athlete_id" })?.value,
                                let athleteName = queryItems.first(where: { $0.name == "athlete_name" })?.value else {
                            continuation.resume(throwing: NetworkControllerError.ErrorLoggingIn)
                            return
                        }
                        
                        
                        print(tokenType)
                        print(accessToken)
                        print(scope)
                        print(athleteId)
                        print(athleteName)
                        
                        continuation.resume(returning: UserProfile(
                            id: athleteId,
                            name: athleteName,
                            authToken: accessToken
                        ))
                }
                    
                authenticationSession.presentationContextProvider = self
                authenticationSession.prefersEphemeralWebBrowserSession = true
                
                DispatchQueue.main.async {
                    authenticationSession.start()
                }
                
            }
            
        }
        
        return try await task.value
        
        
    }
    
    // Logs the user into the server
    func logIn(email: String, password: String) async throws -> UserProfile {
        
        // Ensure an email exists
        guard email.count > 0 else {
            throw NetworkControllerError.NoEmail
        }
        
        // Ensure a password exists
        guard password.count > 0 else {
            throw NetworkControllerError.NoPassword
        }
        
        // Encode password
        guard let passwordEncoded = password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            print("Unable to encode url")
            throw NetworkControllerError.ErrorLoggingIn
        }
        
        // Create URL
        guard let url = URL(string: "https://intervals.icu/api/login?email=\(email)&password=\(passwordEncoded)&deviceClass=mobile") else {
            print("unable to construct url")
            throw NetworkControllerError.ErrorLoggingIn
        }
        
        // Create request to send
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Send request
        var data: Data?
        var response: URLResponse?
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print(error)
            throw NetworkControllerError.ErrorLoggingIn
        }
        
        // Ensure there is a response
        guard let response = response else {
            print("No response")
            throw NetworkControllerError.ErrorLoggingIn
        }
        
        // Convert the response to HTTPURLResponse type
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Unable to create HTTP response")
            throw NetworkControllerError.ErrorLoggingIn
        }
        
        // Handle errors and success
        switch httpResponse.statusCode {
        case 422:
            guard let error = httpResponse.value(forHTTPHeaderField: "error") else {
                throw NetworkControllerError.ErrorLoggingIn
            }
            if error == "No user is registered with that email address" {
                throw NetworkControllerError.UserDoesNotExist
            } else if error == "Incorrect password" {
                throw NetworkControllerError.IncorrectPassword
            } else {
                throw NetworkControllerError.ErrorLoggingIn
            }
        case 200:
            break
        default:
            throw NetworkControllerError.ErrorLoggingIn
        }

        // Parse the JSON data to profile
        var profile: UserProfile? = nil
        do {
            guard let data = data else {
                throw NetworkControllerError.ErrorLoggingIn
            }
            // Use a wrapper to access the UserProfile as a child object
            let serverResponse = try JSONDecoder().decode(RawServerLoginResponse.self, from: data)
            profile = serverResponse.athlete
        } catch {
            print("Unable to parse JSON")
            print(error)
            throw NetworkControllerError.ErrorLoggingIn
        }
        
        // Ensure a profile exists
        guard let profile = profile else {
            throw NetworkControllerError.ErrorLoggingIn
        }
        
        return profile
        
    }
    
    func retrieveActivitiesFromServer(userId: String, authToken: String, oldestDate: Date) async throws -> [Activity] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let oldestDate = dateFormatter.string(from: oldestDate)
        let newestDate = dateFormatter.string(from: Date())
        
        // Construct URl for get request
        guard let url = URL(string: "https://intervals.icu/api/v1/athlete/\(userId)/activities?oldest=\(oldestDate)&newest=\(newestDate)") else {
            print("unable to construct url")
            throw NetworkControllerError.ErrorRetrievingActivitiesData
        }
        
        // Construct request with authorisation
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // Send request
        var data: Data?
        var response: URLResponse?
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print(error)
            throw NetworkControllerError.ErrorRetrievingActivitiesData
        }
        
        // Ensure a response exists
        guard let response = response else {
            print("No response")
            throw NetworkControllerError.ErrorLoggingIn
        }
        
        // Convert response to HTTPURLResponse type
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Unable to create HTTP response")
            throw NetworkControllerError.ErrorLoggingIn
        }
        
        // Handle errors and success
        switch httpResponse.statusCode {
        case 403:
            throw NetworkControllerError.AccessDenied
        case 200:
            break
        default:
            throw NetworkControllerError.ErrorLoggingIn
        }

        // Parse the JSON data to activities array
        var activities: [Activity] = []
        do {
            guard let data = data else {
                throw NetworkControllerError.ErrorRetrievingActivitiesData
            }
            activities = try JSONDecoder().decode([Activity].self, from: data)
            print("Downloaded \(activities.count) new activities")
        } catch {
            print(error)
            print("Unable to parse JSON")
            throw NetworkControllerError.ErrorRetrievingActivitiesData
        }
        
        return activities
        
    }
    
    // Define errors with user readable descriptions
    public enum NetworkControllerError: Error, LocalizedError {
        case AccessDenied
        case NoEmail
        case NoPassword
        case UserDoesNotExist
        case IncorrectPassword
        case ErrorLoggingIn
        case ErrorRetrievingActivitiesData
        
        public var errorDescription: String? {
            switch self {
            case .AccessDenied:
                return NSLocalizedString("Access denied to the server", comment: "")
            case .NoEmail:
                return NSLocalizedString("Please provide an email address", comment: "")
            case .NoPassword:
                return NSLocalizedString("Please provide a password", comment: "")
            case .UserDoesNotExist:
                return NSLocalizedString("Email address not registered on the server", comment: "")
            case .IncorrectPassword:
                return NSLocalizedString("Incorrect password", comment: "")
            case .ErrorLoggingIn:
                return NSLocalizedString("Unable to log in", comment: "")
            case .ErrorRetrievingActivitiesData:
                return NSLocalizedString("Unable to retrieve activities", comment: "")
            }
        }
    }
    
}
