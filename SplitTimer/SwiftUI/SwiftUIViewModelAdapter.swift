//
//  SwiftUIViewModelAdapter.swift
//  SplitTimer
//
//  Created by david lam on 11/6/22.
//  Copyright © 2022 David Lam. All rights reserved.
//

import Foundation
import RxSwift
import SwiftUI

struct ListItem: Identifiable {
    let id = UUID()
    let mainLabelText: String
    let detailLabelText: String
}

class SwiftUIViewModelAdapter: ObservableObject {
    let viewModel = ViewModel()
    let disposeBag = DisposeBag()

    @Published var primaryButtonTitle = ""
    @Published var secondaryButtonTitle = ""
    @Published var secondaryButtonEnabled = false
    @Published var timerLabelText = "00:00:00"
    @Published var listItems: [ListItem] = []

    init() {
        viewModel.output.primaryButtonTitleText
            .subscribe(onNext: { [weak self] title in
                self?.primaryButtonTitle = title
            })
            .disposed(by: disposeBag)

        viewModel.output.secondaryButtonTitleText
            .subscribe(onNext: { [weak self] title in
                self?.secondaryButtonTitle = title
            })
            .disposed(by: disposeBag)

        viewModel.output.secondaryButtonEnabled
            .subscribe(onNext: { [weak self] enabled in
                self?.secondaryButtonEnabled = enabled
            })
            .disposed(by: disposeBag)

        viewModel.output.timerLabelText
            .subscribe(onNext: { [weak self] timerLabel in
                self?.timerLabelText = timerLabel
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.output.lapModels, viewModel.output.displayMode)
            .map({ lapModels, displayMode -> [ListItem] in
                guard lapModels.isEmpty == false else {
                    return []
                }

                let index = (1...lapModels.count).reversed()

                return zip(lapModels, index)
                    .map({ lapModel, index in
                        let mainText = CellConfigurator.getMainLabelText(lap: lapModel,
                                                                         displayMode: displayMode,
                                                                         index: index)
                        let detailText = CellConfigurator.getDetailLabelText(lap: lapModel,
                                                                             displayMode: displayMode)
                        return ListItem(mainLabelText: mainText,
                                        detailLabelText: detailText)
                    })
            })
            .subscribe(onNext: { [weak self] elements in
                self?.listItems = elements
            })
            .disposed(by: disposeBag)
        viewModel.input.displaySegmentControlObserver.onNext(0)
    }

    func didTapPrimaryButton() {
        viewModel.input.primaryButtonTapEventObserver.onNext(())

    }

    func didTapSecondaryButton() {
        viewModel.input.secondaryButtonTapEventObserver.onNext(())
    }

}
