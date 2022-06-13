//
//  KeychainController.swift
//  Intervals
//
//  Created by Matthew Roche on 24/10/2021.
//

import Foundation
import SimpleKeychain

// Control operations getting and setting keychain variables
class KeychainController {
    
    private let serviceName = "fitness-fatigue"
    private let accessGroupName = "A4G3Y5XC83.com.matthewroche.fitnessfatigue.shared"
    private let userProfileKey = "fitness-fatigue-user-profile"
    private let lastSyncKey = "fitness-fatigue-last-sync"
    
    // Produce users profile if it's avaialble
    func getLoginDetails() throws -> UserProfile {
        let keychain = A0SimpleKeychain(service: serviceName, accessGroup: accessGroupName)
        guard let profileString = keychain.string(forKey: userProfileKey) else {
            print("No user profile")
            throw KeychainControllerError.NoUserProfile
        }
        guard let profileData = profileString.data(using: .utf8) else {
            print("Error converting to data")
            removeLoginDetails()
            throw KeychainControllerError.ErrorDecoding
        }
        let decoder = JSONDecoder()
        let userProfile = try decoder.decode(UserProfile.self, from: profileData)
        return userProfile
    }
    
    // Save users profile
    func saveLoginDetails(profile: UserProfile) throws -> Void {
        let keychain = A0SimpleKeychain(service: serviceName, accessGroup: accessGroupName)
        let encoder = JSONEncoder()
        guard let profileString = String(data: try encoder.encode(profile), encoding: .utf8) else {
            throw KeychainControllerError.ErrorEncoding
        }
        keychain.setString(profileString, forKey: userProfileKey)
    }
    
    // Remove users profile
    func removeLoginDetails() -> Void {
        let keychain = A0SimpleKeychain(service: serviceName, accessGroup: accessGroupName)
        keychain.deleteEntry(forKey: userProfileKey)
    }
    
    // Saves the last sync date
    func saveLastSyncDetails(date: Date) -> Void {
        let keychain = A0SimpleKeychain(service: serviceName, accessGroup: accessGroupName)
        let dateString = String(date.timeIntervalSince1970)
        keychain.setString(dateString, forKey: lastSyncKey)
    }
    
    // Produces the last sync date
    func getLastSyncDetails() throws -> Date? {
        let keychain = A0SimpleKeychain(service: serviceName, accessGroup: accessGroupName)
        guard let dateString = keychain.string(forKey: lastSyncKey) else {
            return nil
        }
        guard let dateInterval = Double(dateString) else {
            removeLastSyncDetails()
            throw KeychainControllerError.UnableToDecodeDate
        }
        return Date(timeIntervalSince1970: dateInterval)
    }
    
    // Remove any stored last sync date
    func removeLastSyncDetails() -> Void {
        let keychain = A0SimpleKeychain(service: "intervals", accessGroup: "A4G3Y5XC83.com.matthewroche.intervals.shared")
        keychain.deleteEntry(forKey: lastSyncKey)
    }
    
    // Define errors with user readable descriptions
    public enum KeychainControllerError: Error, LocalizedError {
        case NoUserProfile
        case ErrorEncoding
        case ErrorDecoding
        case UnableToDecodeDate
        
        public var errorDescription: String? {
            switch self {
            case .NoUserProfile:
                return NSLocalizedString("There's no user stored locally", comment: "")
            case .ErrorDecoding:
                return NSLocalizedString("An error occured decoding the user", comment: "")
            case .ErrorEncoding:
                return NSLocalizedString("An error occured encoding the user", comment: "")
            case .UnableToDecodeDate:
                return NSLocalizedString("Couldn't retrieve last sync date", comment: "")
            }
        }
    }
    
}
