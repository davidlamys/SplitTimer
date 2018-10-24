//
//  CellConfiguratorSpec.swift
//  SplitTimerTests
//
//  Created by David Lam on 3/10/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import Nimble
import Quick
import RxSwift
import RxTest

@testable import SplitTimer

final class CellConfiguratorSpec: QuickSpec {
    override func spec() {
        describe("CellConfiguratorSpec") {
            let subject = CellConfigurator.self
            let lap = LapModel(lapTime: 600, splitTime: 1200)
            var mainLabelText: String!
            var detailLabelText: String!
            context("when displaying only lap timing") {
                beforeEach {
                    mainLabelText = subject.getMainLabelText(lap: lap,
                                                             displayMode: .lapOnly,
                                                             index: 1)
                    detailLabelText = subject.getDetailLabelText(lap: lap,
                                                                 displayMode: .lapOnly)
                }
                it("should return the correct text for main label") {
                    expect(mainLabelText) == "Lap 1"
                }
                it("should return the correct text for detail label") {
                    expect(detailLabelText) == "01:00.0"
                }
            }
            context("when displaying only split timing") {
                beforeEach {
                    mainLabelText = subject.getMainLabelText(lap: lap,
                                                             displayMode: .splitOnly,
                                                             index: 1)
                    detailLabelText = subject.getDetailLabelText(lap: lap,
                                                                 displayMode: .splitOnly)
                }
                it("should return the correct text for main label") {
                    expect(mainLabelText) == "Lap 1"
                }
                it("should return the correct text for detail label") {
                    expect(detailLabelText) == "02:00.0"
                }
            }
            context("when displaying both timings") {
                beforeEach {
                    mainLabelText = subject.getMainLabelText(lap: lap,
                                                             displayMode: .both,
                                                             index: 1)
                    detailLabelText = subject.getDetailLabelText(lap: lap,
                                                                 displayMode: .both)
                }
                it("should return the correct text for main label") {
                    expect(mainLabelText) == "02:00.0"
                }
                it("should return the correct text for detail label") {
                    expect(detailLabelText) == "01:00.0"
                }
            }
        }
    }
}
