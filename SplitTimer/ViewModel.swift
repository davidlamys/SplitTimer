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

struct ViewModel: ViewModelType, ViewModelInputType, ViewModelOutputType {
    enum TimerState {
        case started
        case stopped
    }
    
    var input: ViewModelInputType { return self }
    var output: ViewModelOutputType { return self }
    
    // input
    var primaryButtonTapEventObserver = PublishSubject<Void>()
    var secondaryButtonTapEventObserver = PublishSubject<Void>()
    
    // output
    var primaryButtonTitleText: Observable<String> {
        return timerState
            .map(self.primaryButtonTitle)
    }
    
    var secondaryButtonTitleText: Observable<String> {
        return Observable.just("")
    }
    
    var timerLabelText: Observable<String> {
        return Observable.just("")
    }
    
    private var timerState: Observable<TimerState> {
        return primaryButtonTapEventObserver
            .scan(0, accumulator: { (sum, _) -> Int in return sum + 1 })
            .map({ $0 % 2 })
            .map({ $0 == 0 ? .stopped : .started })
            .startWith(.stopped)
            .share()
    }
    
    private func primaryButtonTitle(for timerState: TimerState) -> String {
        switch timerState {
        case .started:
            return "Stop"
        case .stopped:
            return "Start"
        }
    }
}
