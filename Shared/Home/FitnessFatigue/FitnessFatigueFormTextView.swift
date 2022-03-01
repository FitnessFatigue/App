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
    
    var dataToDisplay: (String, String, String, Color) {
        guard let dragPointDay = dragPointDay else {
            
            guard let todaysValues = todaysValues else {
                return ("-", "-", "-", .black)
            }

            return (
                String(Int(todaysValues.fitness)),
                String(Int(todaysValues.fatigue)),
                String(Int(todaysValues.form)),
                todaysValues.formColor
            )
            
        }

        let fitness = "\(Int(fitnessData[dragPointDay].value))"
        let fatique = "\(Int(fatigueData[dragPointDay].value))"
        let form = "\(Int(formData[dragPointDay].value))"
        let formColour = calculateFormColor(form: formData[dragPointDay].value)
        
        return (fitness, fatique, form, formColour)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
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
                    Text("Form:")
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
    @State static var todaysValues: DailyValues? = DailyValues(date: Date(), totalTrainingLoad: 23, fitness: 18, fatigue: 6)
    @State static var dragPointDay: Int? = nil
    static var previews: some View {
        FitnessFatigueFormTextView(fitnessData: $fitnessData, fatigueData: $fatigueData, formData: $formData, todaysValues: $todaysValues, dragPointDay: $dragPointDay)
    }
}
