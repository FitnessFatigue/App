//
//  FitnessFatigueView.swift
//  Intervals
//
//  Created by Matthew Roche on 11/10/2021.
//

import SwiftUI

struct FitnessFatigueView: View {
    
    @ObservedObject var userProfile: UserProfile
    
    @ObservedObject var fitnessFatigueGraphData: GraphData = GraphData(title: "Fitness and Fatigue", lines: [
            LineData(
                label: "Fitness",
                data: [],
                gradientColourStart: Color.blue,
                gradientColourFinish: Color.blue.lighter(by: 0.5)),
            LineData(
                label: "Fatigue",
                data: [],
                gradientColourStart: Color.indigo.lighter(by: 0.2),
                gradientColourFinish: Color.indigo.lighter(by: 0.5))
    ])
    
    @ObservedObject var formGraphData: GraphData = GraphData(title: "Form", lines: [
            LineData(
                label: "Form",
                data: []
            )
            ])
    
    @Binding var fitnessData: [DataPoint]
    @Binding var fatigueData: [DataPoint]
    @Binding var formData: [DataPoint]
    @Binding var fitnessFatigueTimeSelection: FitnessFatigueTimeOptions
    @Binding var todaysValues: DailyValues?
    
    @State var dragPoint: CGPoint? = nil
    @State var dragPointDay: Int? = nil
    @State var dragPointDate: Date? = nil
    
    var retrieveDisplayedValues: () -> Void
    
    var body: some View {
        ScrollView {

            FitnessFatigueFormTextView(
                fitnessData: $fitnessData,
                fatigueData: $fatigueData,
                formData: $formData,
                todaysValues: $todaysValues,
                dragPointDay: $dragPointDay,
                dragPointDate: $dragPointDate,
                fitnessFatigueTimeSelection: $fitnessFatigueTimeSelection,
                isPercentageFitness: $userProfile.isPercentageFitness)
            
            Divider()
            
            Picker(selection: $fitnessFatigueTimeSelection, label:
                Text("Time")
                , content: {
                Text("All").tag(FitnessFatigueTimeOptions.all)
                Text("Six Months").tag(FitnessFatigueTimeOptions.sixMonths)
                Text("One Month").tag(FitnessFatigueTimeOptions.oneMonth)
            })
                .padding()
                .pickerStyle(SegmentedPickerStyle())
                .foregroundColor(Color.accentColor)
                .onChange(of: fitnessFatigueTimeSelection) { _ in
                    retrieveDisplayedValues()
                }
                
            LineGraph(
                dragPoint: $dragPoint,
                dragPointDay: $dragPointDay,
                dragPointDate: $dragPointDate
            )
                .environmentObject(fitnessFatigueGraphData)
                .frame(height: 200)
            
            LineGraph(
                dragPoint: $dragPoint,
                dragPointDay: $dragPointDay,
                dragPointDate: $dragPointDate,
                colourBuckets: [(0, .red), (-30, .green), (-10, .gray), (5, .blue)],
                minGraphLabels: [20, 5, -10, -30]
            )
                .environmentObject(formGraphData)
                .frame(height: 200)
            
        }
        .clipped() //Prevents scrolling through navigation and status bars
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color("AccentOrange"))
        }
        .onChange(of: fitnessData) { newValue in
            fitnessFatigueGraphData.lines[0].data = newValue
        }
        .onChange(of: fatigueData) { newValue in
            fitnessFatigueGraphData.lines[1].data = newValue
        }
        .onChange(of: formData) { newValue in
            formGraphData.lines[0].data = newValue
        }
    }
}

struct FitnessFatigueView_Previews: PreviewProvider {
    @State static var userProfile: UserProfile = UserProfile(id: "lkdjsh", authToken: "dlskg")
    @State static var fitnessData: [DataPoint] = [
        DataPoint(date: produceRelativeDate(15), value: 12),
        DataPoint(date: produceRelativeDate(11), value: 1),
        DataPoint(date: produceRelativeDate(10), value: 15),
        DataPoint(date: produceRelativeDate(7), value: 8),
        DataPoint(date: produceRelativeDate(3), value: 1),
        DataPoint(date: produceRelativeDate(0), value: 12)
    ]
    @State static var fatigueData: [DataPoint] = [
        DataPoint(date: produceRelativeDate(15), value: 2),
        DataPoint(date: produceRelativeDate(11), value: 10),
        DataPoint(date: produceRelativeDate(10), value: 15),
        DataPoint(date: produceRelativeDate(7), value: 18),
        DataPoint(date: produceRelativeDate(3), value: 5),
        DataPoint(date: produceRelativeDate(0), value: 7)
]
    @State static var formData: [DataPoint] = [
        DataPoint(date: produceRelativeDate(3), value: 12),
        DataPoint(date: produceRelativeDate(7), value: 1),
        DataPoint(date: produceRelativeDate(2), value: 15),
        DataPoint(date: produceRelativeDate(10), value: 8),
        DataPoint(date: produceRelativeDate(13), value: 1),
        DataPoint(date: produceRelativeDate(0), value: 12)
    ]
    @State static var labelDataSeries: [String] = ["date1", "date2", "date3"]
    @State static var fitnessFatigueTimeSelection = FitnessFatigueTimeOptions.sixMonths
    @State static var todaysValues: DailyValues? = DailyValues(date: Date(), fitness: 18, fatigue: 7, rampRate: 0.5, ctlLoad: 0, atlLoad: 0)
    @State static var retrieveDisplayedValues: () -> Void = {}
    @State static var detailShown: Bool = false
    static var previews: some View {
        FitnessFatigueView(
            userProfile: userProfile,
            fitnessData: $fitnessData,
            fatigueData: $fatigueData,
            formData: $formData,
            fitnessFatigueTimeSelection: $fitnessFatigueTimeSelection,
            todaysValues: $todaysValues,
            retrieveDisplayedValues: retrieveDisplayedValues)
    }
}
