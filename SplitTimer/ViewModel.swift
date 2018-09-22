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
    var secondaryButtonEnabled: Observable<Bool> { get }
}

struct ViewModel: ViewModelType, ViewModelInputType, ViewModelOutputType {
    enum TimerState {
        case started
        case paused
        case cleared
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
        return timerState
            .map(self.secondaryButtonTitle)
    }
    
    var secondaryButtonEnabled: Observable<Bool> {
        return timerState
            .debug()
            .map({
                switch $0 {
                case .started, .paused:
                    return true
                case .cleared:
                    return false
                }
            })
            .startWith(false)
            .distinctUntilChanged()
    }
    
    var timerLabelText: Observable<String> {
        return Observable.just("")
    }
    
    private var timerState: Observable<TimerState> {
        let stateFromPrimaryButton: Observable<TimerState> = primaryButtonTapEventObserver
            .scan(0, accumulator: { (sum, _) -> Int in return sum + 1 })
            .map({ $0 % 2 })
            .map({ $0 == 0 ? .paused : .started })
            .startWith(.cleared)
        
        let stateFromSecondaryButton: Observable<TimerState> = secondaryButtonTapEventObserver
            .withLatestFrom(stateFromPrimaryButton)
            .map({ state in
                switch state {
                case .started, .cleared: return state
                case .paused: return .cleared
                }
            })
        
        return Observable
            .merge(stateFromPrimaryButton, stateFromSecondaryButton)
            .distinctUntilChanged()
            .share()
    }
    
    private func primaryButtonTitle(for timerState: TimerState) -> String {
        switch timerState {
        case .started:
            return "Stop"
        case .paused, .cleared:
            return "Start"
        }
    }
    
    private func secondaryButtonTitle(for timerState: TimerState) -> String {
        switch timerState {
        case .started, .cleared:
            return "Lap"
        case .paused:
            return "Reset"
        }
    }
}
