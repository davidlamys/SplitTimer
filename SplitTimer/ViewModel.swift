//
//  ViewModel.swift
//  SplitTimer
//
//  Created by David Lam on 22/9/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import Foundation
import RxSwift

protocol ViewModelType {
    var input: ViewModelInputType { get }
    var output: ViewModelOutputType { get }
}

protocol ViewModelInputType {
    var primaryButtonTapEventObserver: PublishSubject<Void> { get }
    var secondaryButtonTapEventObserver: PublishSubject<Void> { get }
}

protocol ViewModelOutputType {
    var primaryButtonTitleText: Observable<String> { get }
    var secondaryButtonTitleText: Observable<String> { get }
    var timerLabelText: Observable<String> { get }
}
