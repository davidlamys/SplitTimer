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
    @State private var displayModeSelection = 0

    var body: some View {
        VStack {
            Spacer()
            Text(viewModel.timerLabelText)
                .font(Font.largeTitle)

            HStack {
                Button(action: viewModel.didTapSecondaryButton,
                       label: { Text(viewModel.secondaryButtonTitle) })
                    .disabled(!viewModel.secondaryButtonEnabled)
                Spacer()
                Button(action: viewModel.didTapPrimaryButton,
                       label: { Text(viewModel.primaryButtonTitle) })
            }
            .padding(60)
            Spacer()
            List(viewModel.listItems) { item in
                HStack {
                    Text(item.mainLabelText)
                        .font(Font.title)
                    Text(item.detailLabelText)
                        .font(Font.body)
                }
            }

            Spacer()

            Picker("Select Mode", selection: $displayModeSelection.onChange(viewModel.didChangePickerSelection)) {
                Text("Split Only").tag(0)
                Text("Lap Only").tag(1)
                Text("Both").tag(2)
            }
            .pickerStyle(.segmented)

        }
    }
}

struct SwiftUISplitTimerPreviews: PreviewProvider {
    static var previews: some View {
        SwiftUISplitTimer()
    }
}

// https://stackoverflow.com/a/60130311
extension Binding {
    /// not needed in iOS 14 +
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
            })
    }
}
