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
            print("Error in NetworkController().retrieveDataFromServer")
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
        
        
        // Calculate daily values from the earliest activity we recieved forwards
        do {
            try calculateFitnessAndFatigue(newDataStartPoint: activities.sorted(by: { lhs, rhs in
                lhs.date < rhs.date
            }).first?.date)
        } catch {
            print(error)
            throw DataControllerError.UnableToCalculateFitnessAndFatigue
        }
        
    }
    
    fileprivate func calculateFitnessAndFatigue(newDataStartPoint: Date? = nil) throws {
        
        // Start Realm in thread safe manner
        guard let realm = try? RealmController().returnContainerisedRealm() else {
            throw DataControllerError.UnableToLoadRealm
        }
        
        // Get most recent available DailyValues
        let mostRecentDailyValues = realm.objects(DailyValues.self).sorted(byKeyPath: "date").last
        
        // Get start point for calculations
        //    1) Use provided start point if available and within current range of calculated values.
        //      1a) If the provided start point is ahead of the most recent calculated values then start at the previous calculations
        //    2) If no start point has been provided
        //      2a) If there are previous calculations start there
        //      2b) Otherwise start at the first stored activity
        //      2c) If there are no stored activities then exit as there is nothing to calculate
        
        // If we've been given a start point use this
        var calculationStartPoint: Date? = newDataStartPoint
        
        if calculationStartPoint != nil && mostRecentDailyValues != nil {
            // Check our start point is within the range of existing daily values
            if calculationStartPoint! > Calendar.current.date(byAdding: .day, value: 1, to: mostRecentDailyValues!.date)! {
                // If not start at the most recent daily value
                calculationStartPoint = Calendar.current.date(byAdding: .day, value: 1, to: mostRecentDailyValues!.date)!
            }
        }
        
        if calculationStartPoint == nil { // If we've not been given a start date
            if mostRecentDailyValues != nil {
                // and there are existing daily values use the most recent of these
                calculationStartPoint = Calendar.current.date(byAdding: .day, value: 1, to: mostRecentDailyValues!.date)
            } else { // If there are no previous daily values start with the first activity
                let firstActivity = realm.objects(Activity.self).sorted(byKeyPath: "date").first
                if firstActivity != nil {
                    calculationStartPoint = firstActivity!.date
                } else {
                    return //If there are no activities there is no calculation to do
                }
            }
        }
        
        // Ensure we have a point to start calculating from
        guard var calculationStartPoint = calculationStartPoint else {
            throw DataControllerError.UnableToCalculateFitnessAndFatigue
        }
        // Ensure we are at the start of the calculated day
        calculationStartPoint = Calendar.current.startOfDay(for: calculationStartPoint)
        
        // Calculate an end date
        // Ensure we include everything that happens today by ending tomorrow morning
        guard var endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else {
            throw DataControllerError.UnableToCalculateFitnessAndFatigue
        }
        endDate = Calendar.current.startOfDay(for: endDate)
        
        // Create an interval to iterate through strating at first entry until today
        let dateInterval = DateInterval(start: calculationStartPoint, end: endDate)
        
        // Find starting values for calculations by finding the values the day before our start date
        // Use 0 if no previous values available
        guard var dayToSearchForPreviousValues = Calendar.current.date(byAdding: .day, value: -1, to: calculationStartPoint) else {
            throw DataControllerError.UnableToCalculateFitnessAndFatigue
        }
        dayToSearchForPreviousValues = Calendar.current.startOfDay(for: dayToSearchForPreviousValues)
        let previousDaysDailyValues = realm.object(
            ofType: DailyValues.self,
            forPrimaryKey: String(dayToSearchForPreviousValues.timeIntervalSince1970)
        )
        var todaysFitness = Double(previousDaysDailyValues?.fitness ?? 0)
        var todaysFatigue = Double(previousDaysDailyValues?.fatigue ?? 0)
        
        // Empty array of values to store at end of calculations
        var dailyValuesToStore: [DailyValues] = []
        
        // Iterate through days in interval
        for date in stride(from: dateInterval.start, to: dateInterval.end, by: 60*60*24) { // Loop through days
            
            // Ensure we are definitely at the start of the day (as 24hrs may not be exactly one day
            let dateToStore = Calendar.current.startOfDay(for: date)
            
            let previousFitness = todaysFitness
            let previousFatigue = todaysFatigue
            
            // Calculate end range of search for activities (ie tomorrow morning)
            guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
                throw DataControllerError.UnableToCalculateFitnessAndFatigue
            }
            
            // Get the total load of activities for this dat
            // https://forum.bikehub.co.za/articles/advice/monitoring-your-training-load-r7477/
            let todaysTSS = realm.objects(Activity.self)
                .filter(NSPredicate(format: "date BETWEEN {%@, %@}", date as CVarArg, endOfDay as CVarArg))
                .map { $0.trainingLoad ?? 0 }
                .reduce(0, +)
            
            // Calculating fitness
            todaysFitness = (Double(previousFitness) * pow(M_E, -1/42))
            todaysFitness = todaysFitness + (Double(todaysTSS) * (1 - pow(M_E, -1/42)))

            // Calculating Fatigue
            todaysFatigue = (Double(previousFatigue) * pow(M_E, -1/7))
            todaysFatigue = todaysFatigue + (Double(todaysTSS) * (1 - pow(M_E, -1/7)))
            
            // Create object for day
            let dailyValue = DailyValues(
                date: dateToStore,
                totalTrainingLoad: todaysTSS,
                fitness: Float(todaysFitness),
                fatigue: Float(todaysFatigue)
            )
            
            // Append to array for later storage
            dailyValuesToStore.append(dailyValue)
        }
        
        // Store all calculated values
        do {
            try realm.write {
                realm.add(dailyValuesToStore, update: .all)
            }
        } catch {
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
