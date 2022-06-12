//
//  FitnessFatigueFormTextView.swift
//  Intervals
//
//  Created by Matthew Roche on 10/10/2021.
//

import SwiftUI

struct FitnessFatigueFormTextView: View {
    
    @Binding var fitnessData: [DataPoint]
    @Binding var fatigueData: [DataPoint]
    @Binding var formData: [DataPoint]
    @Binding var todaysValues: DailyValues?
    @Binding var dragPointDay: Int?
    @Binding var dragPointDate: Date?
    @Binding var fitnessFatigueTimeSelection: FitnessFatigueTimeOptions
    @Binding var isPercentageFitness: Bool
    
    func calculateFormColor(form: CGFloat) -> Color {
        if form > 5 {
            return Color.blue
        } else if form < -30 {
            return Color.red
        } else if form < -10 {
            return Color.green
        } else {
            return Color.gray
        }
    }
    
    var dateToDisplay: String {
        guard let dragPointDate = dragPointDate else {
            return "Values for today"
        }
        return "Values for \(DateFormatter.localizedString(from: dragPointDate, dateStyle: .medium, timeStyle: .none))"
    }
    
    var dataToDisplay: (String, String, String, Color) {
        guard let dragPointDay = dragPointDay else {
            
            guard let todaysValues = todaysValues else {
                return ("-", "-", "-", .black)
            }

            return (
                String(Int(round(todaysValues.fitness))),
                String(Int(round(todaysValues.fatigue))),
                isPercentageFitness ?
                    String(Int(round(todaysValues.formAsPercentage))) :
                    String(Int(round(todaysValues.form))),
                todaysValues.formColor
            )
            
        }
        
        guard dragPointDay < fitnessData.count else {
            return ("-", "-", "-", .black)
        }

        let fitness = "\(Int(round(fitnessData[dragPointDay].value)))"
        let fatique = "\(Int(round(fatigueData[dragPointDay].value)))"
        let form = "\(Int(round(formData[dragPointDay].value)))"
        let formColour = calculateFormColor(form: formData[dragPointDay].value)
        
        return (fitness, fatique, form, formColour)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateToDisplay).padding(.bottom)
            HStack {
                HStack {
                    Text("Fitness:")
                    Text(dataToDisplay.0).foregroundColor(Color("LightBlue")).bold()
                }
                Spacer()
                HStack {
                    Text("Fatigue:")
                    Text(dataToDisplay.1).foregroundColor(Color("Purple")).bold()
                }
                Spacer()
                HStack {
                    isPercentageFitness ? Text("Form (%):") : Text("Form:")
                    Text(dataToDisplay.2).foregroundColor(dataToDisplay.3).bold()
                }
            }
        }.padding()
    }
}

struct FitnessFatigueFormTextView_Previews: PreviewProvider {
    @State static var fitnessData: [DataPoint] = []
    @State static var fatigueData: [DataPoint] = []
    @State static var formData: [DataPoint] = []
    @State static var todaysValues: DailyValues? = DailyValues(date: Date(), fitness: 18, fatigue: 6, rampRate: 0.5, ctlLoad: 12, atlLoad: 12)
    @State static var dragPointDay: Int? = nil
    @State static var dragPointDate: Date? = nil
    @State static var fitnessFatigueTimeSelection: FitnessFatigueTimeOptions = .sixMonths
    @State static var isPercentageFitness: Bool = false
    static var previews: some View {
        FitnessFatigueFormTextView(fitnessData: $fitnessData, fatigueData: $fatigueData, formData: $formData, todaysValues: $todaysValues, dragPointDay: $dragPointDay, dragPointDate: $dragPointDate, fitnessFatigueTimeSelection: $fitnessFatigueTimeSelection, isPercentageFitness: $isPercentageFitness)
    }
}
