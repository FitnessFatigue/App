//
//  FitnessFatigueController.swift
//  Intervals
//
//  Created by Matthew Roche on 12/10/2021.
//

import SwiftUI
import RealmSwift

struct FitnessFatigueController: View {
    
    @ObservedObject var userProfile: UserProfile
    
    @State private var fitnessFatigueTimeSelection: FitnessFatigueTimeOptions = FitnessFatigueTimeOptions.sixMonths
    @State private var todaysValues: DailyValues?
    @State private var fitnessData: [DataPoint] = []
    @State private var fatigueData: [DataPoint] = []
    @State private var formData: [DataPoint] = []
    @State var notificationToken: NotificationToken? = nil
    
    var body: some View {
        FitnessFatigueView(
            userProfile: userProfile,
            fitnessData: $fitnessData,
            fatigueData: $fatigueData,
            formData: $formData,
            fitnessFatigueTimeSelection: $fitnessFatigueTimeSelection,
            todaysValues: $todaysValues,
            retrieveDisplayedValues: retrieveDisplayedValues)
            .onAppear {
                guard let realm = try? RealmController().returnContainerisedRealm() else {
                    return
                }
                retrieveDisplayedValues()
                self.todaysValues = realm.objects(DailyValues.self).last
                // Get notified when daily values updates
                notificationToken = realm.objects(DailyValues.self).observe { [self] (_) in
                    retrieveDisplayedValues()
                    self.todaysValues = realm.objects(DailyValues.self).last
                }
            }
            .onDisappear() {
                guard let notificationToken = notificationToken else {
                    return
                }
                notificationToken.invalidate()
            }
            .onChange(of: userProfile.isPercentageFitness) { newValue in
                retrieveDisplayedValues()
            }
    }
    
    func retrieveDisplayedValues() {
        
        guard let realm = try? RealmController().returnContainerisedRealm() else {
            return
        }
        
        let startDate = Date(timeIntervalSinceNow: fitnessFatigueTimeSelection.timeInterval)
        
        let data = realm.objects(DailyValues.self).filter("date > %@", startDate)
        
        fitnessData = []
        fatigueData = []
        formData = []
        
        data.forEach { values in
            fitnessData.append(DataPoint(date: values.date, value: CGFloat(values.fitness)))
            fatigueData.append(DataPoint(date: values.date, value: CGFloat(values.fatigue)))
            if userProfile.isPercentageFitness {
                formData.append(DataPoint(date: values.date, value: CGFloat(values.formAsPercentage)))
            } else {
                formData.append(DataPoint(date: values.date, value: CGFloat(values.form)))
            }
        }
    }
}

enum FitnessFatigueTimeOptions: CaseIterable {
    case all
    case sixMonths
    case oneMonth
    
    var description : String {
        switch self {
        case .all: return "All"
        case .sixMonths: return "Six Months"
        case .oneMonth: return "One Month"
        }
      }
    
    var timeInterval : TimeInterval {
        switch self {
        case .all: return TimeInterval(-3153600000) //100 Years
        case .sixMonths: return TimeInterval(-15780000)
        case .oneMonth: return TimeInterval(-2630000)
        }
      }
    
    var graphAxisLabels: [String] {
        return [
            Date(timeIntervalSinceNow: self.timeInterval).formattedDateShortString,
            Date(timeIntervalSinceNow: self.timeInterval/2).formattedDateShortString,
            Date().formattedDateShortString
        ]
    }
}
