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
    func loadActivitiesFromServer(userId: String, authToken: String) async throws -> Void {
        
        // Start a Realm version which can be used accross threads
        guard let realm = try? RealmController().returnContainerisedRealm() else {
            throw DataControllerError.UnableToLoadRealm
        }
        
        // Get most recent activity stored locally to define which data we need to obtain
        // If no activities available creat an activity with a date 100 years in the past
        let lastActivity = realm.objects(Activity.self).sorted(byKeyPath: "date").last ?? Activity(id: "0", date: Calendar.current.date(byAdding: .year, value: -100, to: Date())!, trainingLoad: 0)
        // Get the date from this activity
        let oldestDate = lastActivity.date.advanced(by: TimeInterval(1))
            
        // Obtain the required activites
        var activities: [Activity] = []
        do {
            print(userId)
            print(authToken)
            print(oldestDate)
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
                threadedRealm.add(activities)
            }
        } catch {
            print(error)
            throw DataControllerError.UnableToWriteToRealm
        }
        
    }
    
    func loadDailyValuesDataFromServer(userId: String, authToken: String) async throws -> Void {
        
        // Start a Realm version which can be used accross threads
        guard let realm = try? RealmController().returnContainerisedRealm() else {
            throw DataControllerError.UnableToLoadRealm
        }
        
        // Get most recent daily values stored locally to define which data we need to obtain
        // If no data is available create an entry with a date 100 years in the past
        let lastDailyValuesData = realm.objects(DailyValues.self).sorted(byKeyPath: "date").last ?? DailyValues(date: Calendar.current.date(byAdding: .year, value: -100, to: Date())!, fitness: 0, fatigue: 0, rampRate: 0, ctlLoad: 0, atlLoad: 0)
        // Get the date from this activity
        let oldestDate = lastDailyValuesData.date.advanced(by: TimeInterval(1))
        
        // Obtain the required activites
        var dailyValues: [DailyValues] = []
        do {
            print(userId)
            print(authToken)
            print(oldestDate)
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
                threadedRealm.add(dailyValues)
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
