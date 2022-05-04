//
//  intervalsExtension.swift
//  intervalsExtension
//
//  Created by Matthew Roche on 26/10/2021.
//

import WidgetKit
import SwiftUI
import Combine
import RealmSwift
import os

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> FitnessFatigueEntry {
        FitnessFatigueEntry(date: Date(), loggedIn: true, lastSyncDate: Date(), values: DailyValues(date: Date(), fitness: 0, fatigue: 0, rampRate: 0, ctlLoad: 0, atlLoad: 0))
    }

    func getSnapshot(in context: Context, completion: @escaping (FitnessFatigueEntry) -> ()) {
        let entry = FitnessFatigueEntry(date: Date(), loggedIn: true, lastSyncDate: Date(), values: DailyValues(date: Date(), fitness: 0, fatigue: 0, rampRate: 0, ctlLoad: 0, atlLoad: 0))
        completion(entry)
    }
    
    func returnMostRecentValues( completion: @escaping (Timeline<FitnessFatigueEntry>) -> ()) {
        
        RealmController().setUp()
        
        let lastSyncDate = try? KeychainController().getLastSyncDetails()
        
        guard let realm = try? RealmController().returnContainerisedRealm() else {
            os_log("Unable to load Realm in widget", log: Log.table)
            return
        }
        
        var entries: [FitnessFatigueEntry] = []
        
        let currentDate = Date()
        let nextDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
        guard let lastDailyValuesRealm = realm.objects(DailyValues.self).sorted(byKeyPath: "date").last else {
            entries.append(
                FitnessFatigueEntry(
                    date: currentDate,
                    loggedIn: true,
                    lastSyncDate: lastSyncDate,
                    values: nil))
            let timeline = Timeline(entries: entries, policy: .after(nextDate))
            completion(timeline)
            return
        }
        
        // This is required to remove the Realm reference and prevent thread errors as we are in a Task
        let lastDailyValues = DailyValues(date: lastDailyValuesRealm.date, fitness: lastDailyValuesRealm.fitness, fatigue: lastDailyValuesRealm.fatigue, rampRate: lastDailyValuesRealm.rampRate, ctlLoad: lastDailyValuesRealm.ctlLoad, atlLoad: lastDailyValuesRealm.atlLoad)
        
        entries.append(
            FitnessFatigueEntry(
                date: currentDate,
                loggedIn: true,
                lastSyncDate: lastSyncDate,
                values: lastDailyValues))
        
        let timeline = Timeline(entries: entries, policy: .after(nextDate))
        completion(timeline)
        
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<FitnessFatigueEntry>) -> ()) {
        
        RealmController().setUp()
        
        os_log("Updating widget timeline", log: Log.table)
        
        guard let userProfile = try? KeychainController().getLoginDetails() else {
            os_log("No login details found in widget", log: Log.table)
            let entries = [
                FitnessFatigueEntry(
                    date: Date(),
                    loggedIn: false,
                    lastSyncDate: Date(),
                    values: nil)
            ]
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
            return
        }
        
        Task {
            do {
                
                os_log("Starting widget sync", log: Log.table)
                
                try await DataController().loadActivitiesFromServer(
                    userId: userProfile.id,
                    authToken: userProfile.authToken)
                
                // Store sync date
                KeychainController().saveLastSyncDetails(date: Date())
                
                os_log("Sync complete in widget", log: Log.table)
                
                returnMostRecentValues(completion: completion)
                
            } catch {
                // If we fail to load data from the server just continue and display most recent values
                os_log("An error occured during widget sync", log: Log.table)
            }
        }
        
    }
}

struct FitnessFatigueEntry: TimelineEntry {
    let date: Date
    let loggedIn: Bool
    let lastSyncDate: Date?
    let values: DailyValues?
}

struct intervalsExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        
        if entry.loggedIn == false {
            Text("Not logged in")
        } else {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    VStack {
                        Text("Form")
                            .font(.subheadline)
                        Text("\(entry.values != nil ? String(Int(entry.values!.form)) : "-")")
                            .bold()
                            .font(.title)
                            .foregroundColor(entry.values!.formColor)
                    }
                    Spacer()
                    VStack {
                        Spacer()
                        Text("Last Sync")
                            .font(.footnote)
                            .padding(.bottom, 0.1)
                        Spacer()
                        Text("\(entry.lastSyncDate != nil ? entry.lastSyncDate!.formattedTimeShortString : "-")")
                            .font(.footnote)
                        Spacer()
                    }
                }.padding(.bottom, 0)
                Spacer()
                Divider()
                Spacer()
                HStack {
                    VStack {
                        Text("Fitness")
                            .font(.subheadline)
                        Text("\(entry.values != nil ? String(Int(entry.values!.fitness)) : "-")")
                            .bold()
                            .font(.title)
                            .foregroundColor(Color("LightBlue"))
                    }
                    Spacer()
                    VStack {
                        Text("Fatigue")
                            .font(.subheadline)
                        Text("\(entry.values != nil ? String(Int(entry.values!.fatigue)) : "-")")
                            .bold()
                            .font(.title)
                            .foregroundColor(Color("Purple"))
                    }
                }.padding(.top, 1)
            }.padding(.all, 20)
        }
    }
}

@main
struct intervalsExtension: Widget {
    let kind: String = "intervalsExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            intervalsExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("Intervals")
        .description("The intervals widget.")
        .supportedFamilies([.systemSmall])
    }
}

struct intervalsExtension_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            intervalsExtensionEntryView(entry: FitnessFatigueEntry(date: Date(), loggedIn: true, lastSyncDate: Date(), values: DailyValues(date: Date(), fitness: 5, fatigue: 3, rampRate: 0.4, ctlLoad: 3, atlLoad: 2)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            intervalsExtensionEntryView(entry: FitnessFatigueEntry(date: Date(), loggedIn: true, lastSyncDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()) , values: DailyValues(date: Date(), fitness: 5, fatigue: 3, rampRate: 0.4, ctlLoad: 3, atlLoad: 2)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
        
    }
}

private let subsystem = "com.matthewroche.intervals"

struct Log {
  static let table = OSLog(subsystem: subsystem, category: "table")
}
