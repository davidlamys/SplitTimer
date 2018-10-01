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
        viewModel.output.cellModels
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { _, model, cell in
                
                cell.textLabel?.text =  stringFromTimeInterval(ms: model.splitTime)
                cell.detailTextLabel?.text = stringFromTimeInterval(ms: model.lapTime)
            }
            .disposed(by: disposeBag)
    }
}
