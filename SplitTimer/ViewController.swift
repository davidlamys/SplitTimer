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
    }
    
    private func bindTimerLabel(_ viewModel: ViewModelType) {
        viewModel.output.timerLabelText
            .bind(to: self.timerLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
