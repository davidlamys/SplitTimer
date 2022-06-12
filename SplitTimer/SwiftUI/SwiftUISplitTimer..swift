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

        }
    }
}

struct SwiftUISplitTimerPreviews: PreviewProvider {
    static var previews: some View {
        SwiftUISplitTimer()
    }
}
