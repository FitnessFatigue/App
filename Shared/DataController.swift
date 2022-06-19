//
//  DataController.swift
//  Intervals
//
//  Created by Matthew Roche on 12/10/2021.
//

import Foundation
import RealmSwift

// Contains control logic to handle data production, storage and processing
struct DataController {
    
    // Loads and stores activities from the server
    func loadActivitiesFromServer(userId: String, authToken: String, allData: Bool = false) async throws -> Void {
        
        // Start a Realm version which can be used accross threads
        guard let realm = try? RealmController().returnContainerisedRealm() else {
            throw DataControllerError.UnableToLoadRealm
        }
        
        var oldestDate = Date(timeIntervalSince1970: -2208988800)
        if !allData {
            // Get most recent activity stored locally to define which data we need to obtain
            // If no activities available creat an activity with a date 100 years in the past
            let lastActivity = realm.objects(Activity.self).sorted(byKeyPath: "date").last ??
            Activity(id: "0", date: Date(timeIntervalSince1970: -2208988800), trainingLoad: 0)
            // Get the date from this activity
            oldestDate = lastActivity.date
        }
            
        // Obtain the required activites
        var activities: [Activity] = []
        do {
            activities = try await NetworkController().retrieveActivitiesFromServer(userId: userId, authToken: authToken, oldestDate: oldestDate)
        } catch {
            print("Error in NetworkController().retrieveActivitiesFromServer")
            print(error)
            throw error
        }
        
        // Add to Realm - need to init Realm again as may be on different thread after performing await
        guard let threadedRealm = try? RealmController().returnContainerisedRealm() else {
            throw DataControllerError.UnableToLoadRealm
        }
        
        do {
            try threadedRealm.write {
                threadedRealm.add(activities, update: .modified)
            }
        } catch {
            print(error)
            throw DataControllerError.UnableToWriteToRealm
        }
        
    }
    
    func loadDailyValuesDataFromServer(userId: String, authToken: String, allData: Bool = false) async throws -> Void {
        
        // Start a Realm version which can be used accross threads
        guard let realm = try? RealmController().returnContainerisedRealm() else {
            throw DataControllerError.UnableToLoadRealm
        }
        
        var oldestDate = Date(timeIntervalSince1970: -2208988800)
        if !allData {
            // Get most recent activity stored locally to define which data we need to obtain
            // If no activities available creat an activity with a date 100 years in the past
            let lastDailyValue = realm.objects(DailyValues.self).sorted(byKeyPath: "date").last ??
                DailyValues(date: Date(timeIntervalSince1970: -2208988800), fitness: 0, fatigue: 0, rampRate: 0, ctlLoad: 0, atlLoad: 0)
            // Get the date from this activity
            oldestDate = lastDailyValue.date
        }
        
        // Obtain the required activites
        var dailyValues: [DailyValues] = []
        do {
            dailyValues = try await NetworkController().retrieveWellnessFromServer(userId: userId, authToken: authToken, oldestDate: oldestDate)
        } catch {
            print("Error in NetworkController().retrieveWellnessFromServer")
            print(error)
            throw error
        }
        
        // Add to Realm - need to init Realm again as may be on different thread after performing await
        guard let threadedRealm = try? RealmController().returnContainerisedRealm() else {
            throw DataControllerError.UnableToLoadRealm
        }
        
        do {
            try threadedRealm.write {
                threadedRealm.add(dailyValues, update: .modified)
            }
        } catch {
            print(error)
            throw DataControllerError.UnableToWriteToRealm
        }
    
    }
    
    // Define errors with user friendly descriptions
    public enum DataControllerError: Error, LocalizedError {
        case UnableToLoadRealm
        case UnableToWriteToRealm
        case UnableToCalculateFitnessAndFatigue
        case ErrorRetrievingDataFromServer
        
        public var errorDescription: String? {
            switch self {
            case .UnableToLoadRealm:
                return NSLocalizedString("Unable to load the database", comment: "")
            case .UnableToWriteToRealm:
                return NSLocalizedString("Unable to write to the database", comment: "")
            case .UnableToCalculateFitnessAndFatigue:
                return NSLocalizedString("An error occured performing calculations on the data", comment: "")
            case .ErrorRetrievingDataFromServer:
                return NSLocalizedString("Unable to retrieve data from server", comment: "")
            }
        }
    }
    
}
