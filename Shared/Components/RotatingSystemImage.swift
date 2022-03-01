//
//  RotatingImage.swift
//  Intervals
//
//  Created by Matthew Roche on 25/10/2021.
//

import SwiftUI

// Creates a system image which can rotate on demand
struct RotatingSystemImage: View {
    
    // The name of the image
    var systemName: String
    // The colour
    var foregroundColor: Color = Color("AccentOrange")
    
    // Is the image animating
    @Binding var isAnimating: Bool
    
    // The current angle of the image
    @State private var angle: Double = 0
    
    // Define a permanent animation
    var foreverAnimation: Animation {
        Animation.linear(duration: 2.0)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        Image(systemName: systemName)
            .foregroundColor(foregroundColor)
            .rotationEffect(Angle(degrees: angle))
            // Add or remove animation depending on state change
            .animation(self.isAnimating ? foreverAnimation : .linear(duration: 0), value: angle)
            .onAppear(perform: {
                if isAnimating {
                    angle = 360
                }
            })
            .onChange(of: isAnimating) { newValue in
                angle = newValue ? 360.0 : 0.0
            }
    }
}

struct RotatingImage_Previews: PreviewProvider {
    @State static var isAnimating = false
    static var previews: some View {
        Group {
            RotatingSystemImage(systemName: "arrow.2.circlepath", isAnimating: $isAnimating)
                .previewLayout(PreviewLayout.sizeThatFits)
                .padding()
        }
        
    }
}
