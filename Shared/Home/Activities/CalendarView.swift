//
//  CalendarView.swift
//  Intervals
//
//  Created by Matthew Roche on 11/10/2021.
//

import SwiftUI
import RealmSwift

// Contains the calendar display
// Credit to https://gist.github.com/mecid/f8859ea4bdbd02cf5d440d58e936faec
struct CalendarView: View {
    
    // The calendar being displayed
    private let calendar: Calendar
    // Formats months
    private let monthFormatter: DateFormatter
    // Formats days
    private let dayFormatter: DateFormatter
    // Formats weekdays
    private let weekDayFormatter: DateFormatter
    // Formats full dates
    private let fullFormatter: DateFormatter
    // Cache now
    private static var now = Date()
    
    // Updates trainingLoadValues
    var retrieveDisplayedValues: () -> Void
    
    // A dictionary of dates and training load values as a fracion of the maximum value
    @ObservedObject var trainingLoadValues: TrainingLoadValues
    
    // The date selected on the calendar
    @Binding var selectedDate: Date
    
    // Allows DarkMode formatting
    @Environment(\.colorScheme) var colorScheme

    init(calendar: Calendar, retrieveDisplayedValues: @escaping () -> Void, trainingLoadValues: ObservedObject<TrainingLoadValues>, selectedDate: Binding<Date>) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
        self.retrieveDisplayedValues = retrieveDisplayedValues
        self._trainingLoadValues = trainingLoadValues
        self._selectedDate = selectedDate
    }
    
    var body: some View {
        VStack {
            CalendarComponentView(
                calendar: calendar,
                date: $selectedDate,
                trainingLoadValues: _trainingLoadValues,
                content: { date in
                    Button(action: { selectedDate = date }) {
                        Text("00")
                            .padding(8)
                            .foregroundColor(.clear)
                            .background(
                                // Adjust background opacity dependant on intensity of activity that day
                                Color("AccentOrange").opacity(date > Date() ? 0 :
                                    Double(
                                        trainingLoadValues.values[Calendar.current.startOfDay(for: date)] ?? Float(0.0)
                                    )
                                )
                            )
                            .cornerRadius(25)
                            .accessibilityHidden(true)
                            .overlay(
                                // The cicles surrounding the text
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        date > Date() ?
                                            // White if in future
                                            Color.white :
                                            calendar.isDate(date, inSameDayAs: selectedDate) ?
                                                // Orange if selected day
                                                Color("AccentOrange")
                                                : calendar.isDateInToday(date) ?
                                                    // Orange if is Today
                                                    Color("AccentOrange")
                                                    // Otherwise blue
                                                    : .blue
                                        , lineWidth: 2
                                    )
                            )
                            .overlay(
                                // The actual text of the date
                                Text(dayFormatter.string(from: date))
                                    // Grey in future otherwise label colour
                                    .foregroundColor(date > Date() ? .secondary : Color(UIColor.label))
                            )
                    }
                },
                // Display required dates in next month
                trailing: { date in
                    Text(dayFormatter.string(from: date))
                        .foregroundColor(.secondary)
                },
                // The calendar's header (ie S,M,T,W,T etc)
                header: { date in
                    Text(weekDayFormatter.string(from: date))
                },
                // The Calendar's title
                title: { date in
                    HStack {
                        // Month text
                        Text(monthFormatter.string(from: date))
                            .font(.headline)
                            .padding()
                        Spacer()
                        // Back button
                        Button {
                            withAnimation {
                                // Change selected date to one month prior
                                // This will update the displayed month
                                guard let newDate = calendar.date(
                                    byAdding: .month,
                                    value: -1,
                                    to: selectedDate
                                ) else {
                                    return
                                }

                                selectedDate = newDate
                            }
                            // Update trainingLoadValues
                            retrieveDisplayedValues()
                        } label: {
                            Label(
                                title: { Text("Previous") },
                                icon: { Image(systemName: "chevron.left").foregroundColor(Color("AccentOrange")) }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                            .frame(maxHeight: .infinity)
                        }
                        // Forward button
                        Button {
                            withAnimation {
                                // Change selected date to one month in the future
                                // This will update the displayed month
                                guard let newDate = calendar.date(
                                    byAdding: .month,
                                    value: 1,
                                    to: selectedDate
                                ) else {
                                    return
                                }

                                selectedDate = newDate
                            }
                            // Update training load values
                            retrieveDisplayedValues()
                        } label: {
                            Label(
                                title: { Text("Next") },
                                icon: { Image(systemName: "chevron.right").foregroundColor(Color("AccentOrange")) }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                            .frame(maxHeight: .infinity)
                        }
                    }
                }
            )
            .equatable()
        }
        .padding()
    }
}


public struct CalendarComponentView<Day: View, Header: View, Title: View, Trailing: View>: View, Equatable {
    // Injected dependencies
    private var calendar: Calendar
    @Binding private var date: Date
    @ObservedObject private var trainingLoadvalues: TrainingLoadValues
    private let content: (Date) -> Day
    private let trailing: (Date) -> Trailing
    private let header: (Date) -> Header
    private let title: (Date) -> Title

    // Constants
    private let daysInWeek = 7
    
    // Generate array of days to display
    func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
    
    // Make equatable
    public static func == (lhs: CalendarComponentView<Day, Header, Title, Trailing>, rhs: CalendarComponentView<Day, Header, Title, Trailing>) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }

    public init(
        calendar: Calendar,
        date: Binding<Date>,
        trainingLoadValues: ObservedObject<TrainingLoadValues>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder trailing: @escaping (Date) -> Trailing,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title
    ) {
        self.calendar = calendar
        self._date = date
        self._trainingLoadvalues = trainingLoadValues
        self.content = content
        self.trailing = trailing
        self.header = header
        self.title = title
    }

    // Produce the actual calendar
    public var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()

        return LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
            Section(header: title(month)) {
                ForEach(days.prefix(daysInWeek), id: \.self, content: header)
                ForEach(days, id: \.self) { date in
                    if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                        content(date)
                    } else {
                        trailing(date)
                    }
                }
            }
        }
    }
}


private extension Calendar {
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates = [dateInterval.start]

        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }

            guard date < dateInterval.end else {
                stop = true
                return
            }

            dates.append(date)
        }

        return dates
    }

    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
}

private extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}
