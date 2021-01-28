//
//  TimerState.swift
//  SplitTimer
//
//  Created by David Lam on 1/10/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import Foundation

enum TimerState {
    case started
    case paused
    case cleared
}

func titleForPrimaryButton(timerState: TimerState) -> String {
    switch timerState {
    case .started: return "Stop"
    case .paused: return "Resume"
    case .cleared: return "Start"
    }
}

func titleForSecondaryButton(timerState: TimerState) -> String {
    switch timerState {
    case .started, .cleared: return "Lap"
    case .paused: return "Reset"
    }
}
