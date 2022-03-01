//
//  TabBar.swift
//  DarkMaps (iOS)
//
//  Created by Matthew Roche on 30/01/2021.
//

import SwiftUI

// Defines the tab bar
struct TabBar: View {
    
    @Binding var selectedTab: TabOptions
    
    // Calculating the position of the highlight circle on the tab bar.
    var calculatedCircleX: CGFloat {
        let width = (UIScreen.main.bounds.size.width) / 3.35
        switch selectedTab {
        case .fitnessFatigue:
            return -width
        case .activities:
            return 0
        case .settings:
            return width
        }
    }
    
    var body: some View {
        
        ZStack {
            // Highlight capsule
            Capsule()
                .foregroundColor(Color("AccentOrange"))
                .frame(width: 60, height: 45)
                .offset(x: calculatedCircleX)
                .animation(.interpolatingSpring(mass: 0.8, stiffness: 400, damping: 20, initialVelocity: 1), value: calculatedCircleX)
            // Actual tab buttons
            HStack() {
                Spacer()
                TabBarItem(selectedTab: $selectedTab, icon: "chart.bar.fill", selection: .fitnessFatigue)
                Spacer()
                TabBarItem(selectedTab: $selectedTab, icon: "list.dash", selection: .activities)
                Spacer()
                TabBarItem(selectedTab: $selectedTab, icon: "gear", selection: .settings)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.size.height * 0.08)
        .background(Color(UIColor.systemBackground))
    }
}

struct TabBarItem: View {
    
    @Binding var selectedTab: TabOptions
    
    var icon: String
    var selection: TabOptions
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = selection
            }
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(selectedTab == selection ? Color.white : Color(UIColor.label))
                    .frame(width: 30, height: 30)
            }
            .frame(maxWidth: UIScreen.main.bounds.size.width * 0.2, maxHeight: .infinity)
            .padding(.vertical, 20)
        }
    }
}

struct TabBar_Previews: PreviewProvider {
    
    static var previews: some View {
        return Group {
            PreviewWrapper()
                .previewLayout(.fixed(width: 300 , height: 100))
            PreviewWrapper()
                .previewLayout(.fixed(width: 300 , height: 100))
                .preferredColorScheme(.dark)
        }
    }
    
    struct PreviewWrapper: View {
        
        @State var selectedTab: TabOptions = .fitnessFatigue

        var body: some View {
            
            return TabBar(selectedTab: $selectedTab)
        }
    }
    
}
