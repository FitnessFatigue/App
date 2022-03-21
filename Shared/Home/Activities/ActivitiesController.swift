//
//  ActivitiesController.swift
//  Intervals
//
//  Created by Matthew Roche on 12/10/2021.
//

import SwiftUI
import RealmSwift

// Contains the controller for the activities view
struct ActivitiesController: View {
    
    // An observable object containing a dictionary of dates and training load values as a fraction of the maximum that occured that month
    @StateObject var trainingLoadValues: TrainingLoadValues = TrainingLoadValues()
    // The date selected on the calendar
    @State private var selectedDate = Date()
    // The activities the occured on the date selected in the calendar
    @State private var activitesForSelectedDate: [Activity] = []
    // Contains the notification token for the Realm observer
    @State var notificationToken: NotificationToken? = nil
    // An activity which has been selected from the list, nil if none selected
    @State var selectedActivity: Activity? = nil
    
    // Retrieves the values required for the calendar that is displayed
    func retrieveDisplayedValues() -> Void {
        
        // Load Realm
        guard let realm = try? RealmController().returnContainerisedRealm() else {
            return
        }
        
        // Empty the current store of training loads
        trainingLoadValues.values = [:]
        
        // Calculate start and end dates for the displayed month
        guard let startDate = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: selectedDate)
        ) else {
            return
        }
        guard let endDate = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: startDate
        ) else {
            return
        }
        
        // Calculate the maximum training load that occured in this period
        guard let maxTrainingLoad = realm.objects(DailyValues.self)
            .filter(NSPredicate(format: "date BETWEEN {%@, %@}", startDate as CVarArg,  endDate as CVarArg))
                .max(ofProperty: "totalTrainingLoad") as Float? else {
            return
        }
        
        // Calulate the value of the training load for each day of the month as a fraction of the maximum
        realm.objects(DailyValues.self)
            .filter(NSPredicate(format: "date BETWEEN {%@, %@}", startDate as CVarArg,  endDate as CVarArg))
            .forEach {
                trainingLoadValues.values[Calendar.current.startOfDay(for: $0.date)] = $0.totalTrainingLoad / maxTrainingLoad
            }
    }
    
    // Closes the activity detail sheet
    func closeSheet() {self.selectedActivity = nil}
    
    var body: some View {
        ActivitiesView(
            trainingLoadValues: trainingLoadValues,
            selectedDate: $selectedDate,
            activitesForSelectedDate: $activitesForSelectedDate,
            selectedActivity: $selectedActivity,
            retrieveDisplayedValues: retrieveDisplayedValues,
            closeSheet: closeSheet)
            .onAppear {
                // When the view loads retrieve the values for the current month and create an observer for when the stored values change
                retrieveDisplayedValues()
                
                // Get notified when daily values updates
                guard let realm = try? RealmController().returnContainerisedRealm() else {
                    return
                }
                notificationToken = realm.objects(DailyValues.self).observe { [self] (_) in
                    // Update the displayed values when the underlying data changes
                    retrieveDisplayedValues()
                }
            }
            .onDisappear() {
                // Remove the observer when the view is destroyed
                guard let notificationToken = notificationToken else {
                    return
                }
                notificationToken.invalidate()
            }
            .onChange(of: selectedDate) { newDate in
                // Update the displayed activities when the selected date changes
                guard let realm = try? RealmController().returnContainerisedRealm() else {
                    return
                }
                guard let endDate = Calendar.current.date(byAdding: .day, value: 1, to: newDate) else {
                    return
                }
                activitesForSelectedDate = Array(realm.objects(Activity.self).filter("date BETWEEN {%@, %@}", newDate as CVarArg,  endDate as CVarArg))
            }
    }
}
