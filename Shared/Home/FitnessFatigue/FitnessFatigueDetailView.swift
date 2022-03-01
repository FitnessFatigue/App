//
//  FitnessFatigueDetailView.swift
//  Intervals
//
//  Created by Matthew Roche on 08/11/2021.
//

import SwiftUI


struct FitnessFatigueDetailView: View {
    
    @Binding var detailShown: Bool
    
    @State var fitnessDataSeries: [Double] = []
    @State var fatigueDataSeries: [Double] = []
    @State var labelDataSeries: [String] = []
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 4).foregroundColor(Color("LightBlue")).frame(width: 20, height: 20)
                        Text("Fitness").font(.caption)
                    }
                    HStack {
                        RoundedRectangle(cornerRadius: 4).foregroundColor(Color("Purple")).frame(width: 20, height: 20)
                        Text("Fatigue").font(.caption)
                    }
                }
                Spacer()
                Button(action: {detailShown.toggle()}) {
                    Text("Done").foregroundColor(Color("AccentOrange"))
                }
            }
            FitnessFatigueDetailGraph(
                fitnessDataSeries: $fitnessDataSeries,
                fatigueDataSeries: $fatigueDataSeries,
                labelDataSeries: $labelDataSeries)
        }.onAppear {
            retrieveDisplayedValues()
        }
    }
    
    func retrieveDisplayedValues() {
        
        print("retrieveDisplayedValues()")
        
        guard let realm = try? RealmController().returnContainerisedRealm() else {
            return
        }
        
        let data = realm.objects(DailyValues.self)
        
        self.fitnessDataSeries = Array(data.map { Double($0.fitness) })
        self.fatigueDataSeries = Array(data.map { Double($0.fatigue) })
        self.labelDataSeries = Array(data.map { $0.date.formattedDateShortString })
        
        print("Updated state")
        
    }
    
}

struct FitnessFatigueDetailGraph: UIViewControllerRepresentable {
    
    @Binding var fitnessDataSeries: [Double]
    @Binding var fatigueDataSeries: [Double]
    @Binding var labelDataSeries: [String]
    
    func makeUIViewController(context: Context) -> FitnessFatigueDetailGraphController {
        let controller = FitnessFatigueDetailGraphController()
        controller.fitnessDataSeries = fitnessDataSeries
        controller.fatigueDataSeries = fatigueDataSeries
        controller.labelDataSeries = labelDataSeries
        return controller
    }
    
    func updateUIViewController(_ uiViewController: FitnessFatigueDetailGraphController, context: Context) {
        print("Updating uiVIewController")
        uiViewController.fitnessDataSeries = fitnessDataSeries
        uiViewController.fatigueDataSeries = fatigueDataSeries
        uiViewController.labelDataSeries = labelDataSeries
        uiViewController.viewDidLoad()
    }
    
    typealias UIViewControllerType = FitnessFatigueDetailGraphController
}

class FitnessFatigueDetailGraphController: UIViewController {
    
    var graphViewController: GraphViewController? = nil
    var graphView: ScrollableGraphView? = nil
    var graphConstraints = [NSLayoutConstraint]()
    
    
    var fitnessDataSeries: [Double] = []
    var fatigueDataSeries: [Double] = []
    var labelDataSeries: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(fitnessDataSeries.count)
        
        if graphView != nil {
            self.graphView!.removeFromSuperview()
        }
            
        graphViewController = GraphViewController(
            fitnessArray: fitnessDataSeries,
            fatigueArray: fatigueDataSeries,
            xAxisLabels: labelDataSeries)
        
        guard let graphViewController = graphViewController else {
            return
        }

            
        graphView = graphViewController.createSimpleGraph(self.view.frame)
        
        guard let graphView = graphView else {
            return
        }
            
        self.view.insertSubview(graphView, at: 0)
            
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        guard let graphView = graphView else {
            return
        }
            
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphConstraints.removeAll()
        
        let topConstraint = NSLayoutConstraint(item: graphView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: graphView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: graphView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: graphView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
        
        //let heightConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        
        graphConstraints.append(topConstraint)
        graphConstraints.append(bottomConstraint)
        graphConstraints.append(leftConstraint)
        graphConstraints.append(rightConstraint)
        
        //graphConstraints.append(heightConstraint)
        
        self.view.addConstraints(graphConstraints)
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct FitnessFatigueDetailGraph_Previews: PreviewProvider {
    @State static var fitnessDataSeries: [Double] = [6, 4, 7, 2, 8, 9]
    @State static var fatigueDataSeries: [Double] = [2, 5, 7, 8, 3, 4]
    @State static var labelDataSeries: [String] = ["One", "Two", "Three", "Four", "Five", "Six"]
    static var previews: some View {
        FitnessFatigueDetailGraph(fitnessDataSeries: $fitnessDataSeries, fatigueDataSeries: $fatigueDataSeries, labelDataSeries: $labelDataSeries)
            .preferredColorScheme(.dark)
    }
}
