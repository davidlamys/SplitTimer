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
    var displaySegmentControlObserver: PublishSubject<Int> { get }
}

protocol ViewModelOutputType {
    var primaryButtonTitleText: Observable<String> { get }
    var secondaryButtonTitleText: Observable<String> { get }
    var secondaryButtonEnabled: Observable<Bool> { get }
    var timerLabelText: Observable<String> { get }
    var lapModels: Observable<[LapModel]> { get }
    var displayMode: Observable<DisplayMode> { get }
}

struct ViewModel: ViewModelType, ViewModelInputType, ViewModelOutputType {

    private var disposeBag = DisposeBag()
    
    var input: ViewModelInputType { return self }
    var output: ViewModelOutputType { return self }
    
    // input
    var primaryButtonTapEventObserver = PublishSubject<Void>()
    var secondaryButtonTapEventObserver = PublishSubject<Void>()
    var displaySegmentControlObserver = PublishSubject<Int>()

    // output
    var primaryButtonTitleText: Observable<String> {
        return timerState
            .map(titleForPrimaryButton)
    }
    
    var secondaryButtonTitleText: Observable<String> {
        return timerState
            .map(titleForSecondaryButton)
    }
    
    var secondaryButtonEnabled: Observable<Bool> {
        return timerState
            .map({
                switch $0 {
                case .started, .paused: return true
                case .cleared: return false
                }
            })
            .startWith(false)
            .distinctUntilChanged()
    }
    
    var timerLabelText: Observable<String> {
        return currentRunningTime
            .map(stringFromTimeInterval)
    }
    
    var lapModels: Observable<[LapModel]> {
        return Observable
            .zip(lapTimings, splitTimings)
            .map({ (laps, splits) in
                return zip(laps, splits)
                    .map({ (lap, split) -> LapModel in
                        return LapModel(lapTime: lap, splitTime: split)
                    })
            })
    }
    
    var displayMode: Observable<DisplayMode> {
        return displaySegmentControlObserver
            .map({
                switch $0 {
                case 0: return .splitOnly
                case 1: return .lapOnly
                default: return .both
                }
            })
    }
    
    init(timer: Observable<Void> = TimerFactory.makeTimer(),
         timerStateStream: Observable<TimerState>? = nil) {
        let stateStream = timerStateStream ?? self.timerState
        
        timer.withLatestFrom(stateStream)
            .scan(0, accumulator: calculateRunningTime)
            .distinctUntilChanged()
            .bind(to: currentRunningTime)
            .disposed(by: disposeBag)
    }
    
    private var timer: Observable<Int>!
    private var currentRunningTime = PublishSubject<Int>()

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
    
    private var splitTimings: Observable<[Int]> {
        return Observable.combineLatest(currentRunningTime, lapCount)
            .scan([Int]()) { (timingArray, latestInput) -> [Int] in
                let (runningTime, lapCount) = latestInput
                
                guard lapCount != 0 else {
                    return []
                }
                
                var timings = timingArray
                if timings.count == lapCount {
                    timings[0] = runningTime
                    return timings
                } else {
                    timings.insert(runningTime, at: 0)
                    return timings
                }
        }
    }
    
    private var lapTimings: Observable<[Int]> {
        return Observable.combineLatest(currentRunningTime, lapCount)
            .scan([Int]()) { (currentArray, latestInput) -> [Int] in
                let (runningTime, lapCount) = latestInput
                
                guard lapCount != 0 else {
                    return []
                }
                
                if lapCount == 1 && runningTime == 1 {
                    return [1]
                }
                
                var timings = currentArray
                let totalTimeBeforeCurrentLap = currentArray.reduce(-(currentArray.first ?? 0), +)
                let currentLapTime = runningTime - totalTimeBeforeCurrentLap
                if currentArray.count == lapCount {
                    timings[0] = currentLapTime
                    return timings
                } else {
                    timings.insert(0, at: 0)
                    return timings
                }
        }
    }
    
    private var lapCount: Observable<Int> {
        enum SplitLapCommand {
            case addLaps
            case reset
        }
        
        let splitButtonPressed = secondaryButtonTapEventObserver
            .withLatestFrom(timerState)
            .filter({ $0 == .started })
            .map({ _ in SplitLapCommand.addLaps })
        
        let start = timerState
            .scan((nil, nil), accumulator: { ($0.1, $1) })
            .filter({ $0 == (.cleared, .started) })
            .map({ _ in SplitLapCommand.addLaps })
        
        let resetLaps = timerState
            .filter({ $0 == .cleared })
            .map({ _ in SplitLapCommand.reset })
        
        return Observable.merge(start,
                                splitButtonPressed,
                                resetLaps)
            .scan(0, accumulator: { (runningCount, command) in
                switch command {
                case .addLaps: return runningCount + 1
                case .reset: return 0
                }
            })
    }
    
    private func calculateRunningTime(runningTime: Int, latestState: TimerState) -> Int {
        switch latestState {
        case .started: return runningTime + 1
        case .paused: return runningTime
        case .cleared: return 0
        }
    }
    
}

private struct TimerFactory {
    static func makeTimer() -> Observable<Void> {
        return Observable<Int>
            .interval(0.1, scheduler: MainScheduler.instance)
            .map({ _ in })
    }
}
