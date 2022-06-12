//
//  SwiftUISplitTimer.swift.swift
//  SplitTimer
//
//  Created by david lam on 11/6/22.
//  Copyright © 2022 David Lam. All rights reserved.
//

import SwiftUI

struct SwiftUISplitTimer: View {
    @StateObject var viewModel = SwiftUIViewModelAdapter()

    var body: some View {
        VStack {
            Text("0:00:00")
            HStack {
                Button(action: {

                }, label: {
                    Text("Lap")
                })
                Button(action: {

                }, label: {
                    Text("Start")
                })
            }
        }
    }
}

struct SwiftUISplitTimerPreviews: PreviewProvider {
    static var previews: some View {
        SwiftUISplitTimer()
    }
}
