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
    
    func retrieveActivitiesFromServer(userId: String, authToken: String, oldestDate: Date) async throws -> [Activity] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let oldestDate = dateFormatter.string(from: oldestDate)
        let newestDate = dateFormatter.string(from: Date())
        
        // Construct URl for get request
        guard let url = URL(string: "https://intervals.icu/api/v1/athlete/\(userId)/activities?oldest=\(oldestDate)&newest=\(newestDate)") else {
            print("unable to construct url")
            throw NetworkControllerError.ErrorConstructingActivitiesURL
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
            throw NetworkControllerError.NoResponseFromServer
        }
        
        // Convert response to HTTPURLResponse type
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Unable to create HTTP response")
            throw NetworkControllerError.InvalidResponseFromServer
        }
        
        // Handle errors and success
        switch httpResponse.statusCode {
        case 403:
            throw NetworkControllerError.AccessDenied
        case 200:
            break
        default:
            throw NetworkControllerError.UnknownResponseFromServer
        }

        // Parse the JSON data to activities array
        var activities: [Activity] = []
        do {
            guard let data = data else {
                throw NetworkControllerError.InvalidActivitiesDataFromServer
            }
            activities = try JSONDecoder().decode([Activity].self, from: data)
            print("Downloaded \(activities.count) new activities")
        } catch {
            print(error)
            print("Unable to parse JSON")
            throw NetworkControllerError.UnableToDecodeActivitiesDataFromServer(error.localizedDescription)
        }
        
        return activities
        
    }
    
    func retrieveWellnessFromServer(userId: String, authToken: String, oldestDate: Date) async throws -> [DailyValues] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let oldestDate = dateFormatter.string(from: oldestDate)
        let newestDate = dateFormatter.string(from: Date())
        
        // Construct URl for get request
        guard let url = URL(string: "https://intervals.icu/api/v1/athlete/\(userId)/wellness?oldest=\(oldestDate)&newest=\(newestDate)") else {
            print("unable to construct url")
            throw NetworkControllerError.ErrorConstructingWellnessURL
        }
        
        print(url)
        
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
            throw NetworkControllerError.ErrorRetrievingWellnessData
        }
        
        // Ensure a response exists
        guard let response = response else {
            print("No response")
            throw NetworkControllerError.NoResponseFromServer
        }
        
        // Convert response to HTTPURLResponse type
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Unable to create HTTP response")
            throw NetworkControllerError.InvalidResponseFromServer
        }
        print((httpResponse.statusCode))
        
        // Handle errors and success
        switch httpResponse.statusCode {
        case 403:
            throw NetworkControllerError.AccessDenied
        case 200:
            break
        default:
            throw NetworkControllerError.UnknownResponseFromServer
        }

        // Parse the JSON data to activities array
        var dailyValues: [DailyValues] = []
        do {
            guard let data = data else {
                throw NetworkControllerError.InvalidWellnessDataFromServer
            }
            dailyValues = try JSONDecoder().decode([DailyValues].self, from: data)
            print("Downloaded \(dailyValues.count) new daily values")
        } catch {
            print(error)
            print("Unable to parse JSON")
            throw NetworkControllerError.UnableToDecodeWellnessDataFromServer(error.localizedDescription)
        }
        
        return dailyValues
        
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
        case ErrorRetrievingWellnessData
        case ErrorConstructingActivitiesURL
        case ErrorConstructingWellnessURL
        case NoResponseFromServer
        case InvalidResponseFromServer
        case UnknownResponseFromServer
        case InvalidActivitiesDataFromServer
        case InvalidWellnessDataFromServer
        case UnableToDecodeActivitiesDataFromServer(String)
        case UnableToDecodeWellnessDataFromServer(String)
        
        
        public var errorDescription: String? {
            switch self {
            case .AccessDenied:
                return NSLocalizedString("Access denied to the server, try logging out and in again", comment: "")
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
            case .ErrorRetrievingWellnessData:
                return NSLocalizedString("Unable to retrieve wellness data", comment: "")
            case .ErrorConstructingActivitiesURL:
                return NSLocalizedString("Unable to construt URL to access server for activities", comment: "")
            case .ErrorConstructingWellnessURL:
                return NSLocalizedString("Unable to construt URL to access server for wellness data", comment: "")
            case .NoResponseFromServer:
                return NSLocalizedString("There was no response from the server", comment: "")
            case .InvalidResponseFromServer:
                return NSLocalizedString("The response from the server was invalid", comment: "")
            case .UnknownResponseFromServer:
                return NSLocalizedString("Unexpected response fom the server", comment: "")
            case .InvalidActivitiesDataFromServer:
                return NSLocalizedString("The activities data received from the server is invalid", comment: "")
            case .InvalidWellnessDataFromServer:
                return NSLocalizedString("The wellness data received from the server is invalid", comment: "")
            case .UnableToDecodeActivitiesDataFromServer(let errorValue):
                return NSLocalizedString("Unable to decode the data from the server (\(errorValue))", comment: "")
            case .UnableToDecodeWellnessDataFromServer(let errorValue):
                return NSLocalizedString("Unable to decode the data from the server (\(errorValue))", comment: "")
            }
        }
    }
    
}
