//
//  ActivitiesView.swift
//  Intervals
//
//  Created by Matthew Roche on 11/10/2021.
//

import SwiftUI
import simd

// Contains the UI for the Activities page
struct ActivitiesView: View {
    
    // An observable dictionary of dates and training load values as a fraction of the maximum in the currently displayed month
    @ObservedObject var trainingLoadValues: TrainingLoadValues
    // The date selected in the calendar
    @Binding var selectedDate: Date
    // The activities that occured on this date
    @Binding var activitesForSelectedDate: [Activity]
    // The activity selected and displayed on the detail sheet (nil if sheet not displayed)
    @Binding var selectedActivity: Activity?
    // Function to update trainingLoadValues
    var retrieveDisplayedValues: () -> Void
    // Function to cloase the ActivitySheet
    var closeSheet: () -> Void
    
    var body: some View {
        VStack {
            // The Calendar
            CalendarView(
                calendar: Calendar(identifier: .gregorian),
                retrieveDisplayedValues: retrieveDisplayedValues,
                trainingLoadValues: _trainingLoadValues,
                selectedDate: $selectedDate)
            
            // Title of the selected date
            HStack {
                Text("Activities for \(selectedDate.formattedDateLongString)").font(.title2)
                Spacer()
            }.padding(.horizontal)
            
            // A list of activites for the selected date
            ScrollView {
                Divider()
                ForEach(activitesForSelectedDate) { i in
                    Button(action: {selectedActivity = i}) {
                        HStack(alignment: .center) {
                            Text(i.date.formattedDateLongString).foregroundColor(Color(UIColor.label))
                            Spacer()
                            Text("Load:").foregroundColor(Color(UIColor.label))
                            Text(i.formattedTrainingLoad)
                                .foregroundColor(Color(UIColor.label))
                                .padding(.horizontal)
                            Image(systemName: "chevron.right").foregroundColor(Color("AccentOrange"))
                        }.padding().cornerRadius(25)
                    }
                    Divider()
                }
                if activitesForSelectedDate.count == 0 {
                    Text("None to display").padding()
                    Divider()
                }
            }
            .padding(.horizontal)
            
            // The ActivitiesSheet
            Text("").hidden()
                .sheet(item: $selectedActivity) { i in
                    ActivitesSheet(activity: i, closeSheet: closeSheet)
                }
            
            
        }.navigationBarTitleDisplayMode(.inline)
    }
}

struct ActivitiesView_Previews: PreviewProvider {
    
    @State static var newTrainingLoadValues: TrainingLoadValues = TrainingLoadValues(values: [
        Calendar.current.startOfDay(for: Date()): 1,
        Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: -60*60*24*3)): 0.5,
        Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: -60*60*24*4)): 0.2,
        Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: -60*60*24*6)): 0.6,
        Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: -60*60*24*12)): 0.5
    ])
    @State static var selectedActivity: Activity? = nil
    @State static var selectedDate = Date()
    @State static var activitesForSelectedDate = [
        Activity(id: 1, date: Date(), trainingLoad: 7),
        Activity(id: 2, date: Date(), trainingLoad: nil),
        Activity(id: 3, date: Date(), trainingLoad: 17)
    ]
    static var previews: some View {
        ActivitiesView(
            trainingLoadValues: newTrainingLoadValues,
            selectedDate: $selectedDate,
            activitesForSelectedDate: $activitesForSelectedDate,
            selectedActivity: $selectedActivity,
            retrieveDisplayedValues: { },
            closeSheet: { })
    }
}
