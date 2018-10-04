//
//  ViewController.swift
//  SplitTimer
//
//  Created by David Lam on 21/9/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

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
        viewModel.output.lapModels
            .withLatestFrom(viewModel.output.displayMode, resultSelector: { (lapModels, displayMode) -> [(LapModel, DisplayMode, Int)] in
                
                //TODO: refactor this for sanity
                
                let lapModelWithDisplayMode = lapModels
                    .map({ ($0, displayMode) })
                
                return lapModelWithDisplayMode
                        .reduce([(LapModel, DisplayMode, Int)]()) { (array, arg) -> [(LapModel, DisplayMode, Int)] in
                        return array + [(arg.0, arg.1, lapModelWithDisplayMode.count - array.count)]
                        }
            })
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { _, model, cell in
                cell.textLabel?.text =  CellConfigurator.getMainLabelText(lap: model.0, displayMode: model.1, index: model.2)
                cell.detailTextLabel?.text = CellConfigurator.getDetailLabelText(lap: model.0, displayMode: model.1)
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
