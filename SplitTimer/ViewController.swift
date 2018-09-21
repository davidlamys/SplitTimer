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

    private func setupBinding(_ viewModel: ViewModelType) {
        disposeBag = DisposeBag()
        bindPrimaryButton(viewModel)
    }
    
    private func bindPrimaryButton(_ viewModel: ViewModelType) {
        primaryButton.rx.tap
            .bind(to: viewModel.input.primaryButtonTapEventObserver)
            .disposed(by: disposeBag)
        
        viewModel.output.primaryButtonTitleText
            .bind(to: self.primaryButton.rx.title())
            .disposed(by: disposeBag)
    }
}
