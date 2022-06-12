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

class SwiftUIViewModelAdapter: ObservableObject {
    let viewModel = ViewModel()
    let disposeBag = DisposeBag()

    @Published var primaryButtonTitle = ""
    @Published var secondaryButtonTitle = ""
    @Published var secondaryButtonEnabled = false
    @Published var timerLabelText = "00:00:00"

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

    }

    func didTapPrimaryButton() {
        viewModel.input.primaryButtonTapEventObserver.onNext(())

    }

    func didTapSecondaryButton() {
        viewModel.input.secondaryButtonTapEventObserver.onNext(())
    }

}
