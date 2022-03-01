//
//  LoadingView.swift
//  Intervals
//
//  Created by Matthew Roche on 25/10/2021.
//

import SwiftUI

// A view displayed whilst we determine whether the user is logged in.
struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Loading").foregroundColor(Color("AccentOrange")).font(.title)
                Spacer()
            }
            Spacer()
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
