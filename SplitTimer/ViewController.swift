//
//  ViewController.swift
//  SplitTimer
//
//  Created by David Lam on 21/9/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var displayModeSegmentControl: UISegmentedControl!

    var viewModel: ViewModelType! {
        didSet {
            self.setupBinding(viewModel)
        }
    }

    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        if viewModel == nil {
            viewModel = ViewModel()
        }
    }

    private func setupBinding(_ viewModel: ViewModelType) {
        disposeBag = DisposeBag()
        bindPrimaryButton(viewModel)
        bindSecondaryButton(viewModel)
        bindTimerLabel(viewModel)
        bindTableView(viewModel)
        bindSegmentControl(viewModel)
    }

    private func bindPrimaryButton(_ viewModel: ViewModelType) {
        primaryButton.rx.tap
            .bind(to: viewModel.input.primaryButtonTapEventObserver)
            .disposed(by: disposeBag)

        viewModel.output.primaryButtonTitleText
            .bind(to: self.primaryButton.rx.title())
            .disposed(by: disposeBag)
    }

    private func bindSecondaryButton(_ viewModel: ViewModelType) {
        secondaryButton.rx.tap
            .bind(to: viewModel.input.secondaryButtonTapEventObserver)
            .disposed(by: disposeBag)

        viewModel.output.secondaryButtonTitleText
            .bind(to: self.secondaryButton.rx.title())
            .disposed(by: disposeBag)

        viewModel.output.secondaryButtonEnabled
            .bind(to: self.secondaryButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    private func bindTimerLabel(_ viewModel: ViewModelType) {
        viewModel.output.timerLabelText
            .bind(to: self.timerLabel.rx.text)
            .disposed(by: disposeBag)
    }

    private func bindTableView(_ viewModel: ViewModelType) {
        typealias CellModel = (lapData: LapModel, displayMode: DisplayMode, lapNumber: Int)

        viewModel.output.lapModels
            .withLatestFrom(viewModel.output.displayMode, resultSelector: { lapModels, displayMode -> [CellModel] in
                guard lapModels.isEmpty == false else {
                    return []
                }

                let index = (1...lapModels.count).reversed()

                return zip(lapModels, index)
                    .map({ ($0, displayMode, $1) })
            })
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { _, model, cell in
                cell.textLabel?.text = CellConfigurator.getMainLabelText(lap: model.lapData,
                                                                          displayMode: model.displayMode,
                                                                          index: model.lapNumber)

                cell.detailTextLabel?.text = CellConfigurator.getDetailLabelText(lap: model.lapData,
                                                                                 displayMode: model.displayMode)
            }
            .disposed(by: disposeBag)
    }

    private func bindSegmentControl(_ viewModel: ViewModelType) {
        displayModeSegmentControl.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .bind(to: viewModel.input.displaySegmentControlObserver)
            .disposed(by: disposeBag)
    }
}
