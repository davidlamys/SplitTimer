//
//  CellConfigurator.swift
//  SplitTimer
//
//  Created by David Lam on 3/10/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import Foundation

struct CellConfigurator {
    static func getMainLabelText(lap: LapModel, displayMode: DisplayMode, index: Int) -> String {
        switch displayMode {
        case .lapOnly, .splitOnly:
            return "Lap \(index)"
        case .both:
            let splitTiming = lap.splitTime
            return stringFromTimeInterval(ms: splitTiming)
        }
    }
    
    static func getDetailLabelText(lap: LapModel, displayMode: DisplayMode) -> String {
        switch displayMode {
        case .splitOnly:
            let splitTiming = lap.splitTime
            return stringFromTimeInterval(ms: splitTiming)
        case .lapOnly, .both:
            let lapTiming = lap.lapTime
            return stringFromTimeInterval(ms: lapTiming)
        }
    }
}
