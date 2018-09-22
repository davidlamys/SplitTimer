//
//  StringHelpers.swift
//  SplitTimer
//
//  Created by David Lam on 22/9/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import Foundation

func stringFromTimeInterval(ms: Int) -> String {
    return String(format: "%0.2d:%0.2d.%0.1d",
                  arguments: [(ms / 600) % 600, (ms % 600 ) / 10, ms % 10])
}
