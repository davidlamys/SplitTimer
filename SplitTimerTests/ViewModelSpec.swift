//
//  ViewModelSpec.swift
//  SplitTimerTests
//
//  Created by David Lam on 22/9/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxTest

@testable import SplitTimer

final class ViewModelSpec: QuickSpec {
    override func spec() {
        describe("ViewModel spec") {
            var subject: ViewModel!
            var titles: [String]!

            beforeEach {
                subject = ViewModel()
            }
            
            // MARK: Primary button text output
            context("ViewModel should give correct output for Primary Button Text") {
                
                context("Initial value") {
                    beforeEach {
                        titles = ViewModelSpecHelper.getInitialTitle(from: subject.primaryButtonTitleText)
                    }
                    it("Output should be `Start`") {
                        expect(titles.count).to(be(1))
                        expect(titles.last).to(be("Start"))
                    }
                }
                
                context("Should toggle from Start to Stop and back to start based on number of taps") {
                    beforeEach {
                        let testInput = {
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                        }
                        titles = ViewModelSpecHelper.getTitles(from: subject.primaryButtonTitleText,
                                                               basedOn: testInput)
                    }
                    it("Output should be correct") {
                        expect(titles).to(equal(["Start",
                                                 "Stop",
                                                 "Start",
                                                 "Stop",
                                                 "Start"]))
                    }
                }
            }
            
            // MARK: Secondary button text output
            context("ViewModel should give correct output for Secondary Button Text") {
                
                context("when setting initial value") {
                    beforeEach {
                        titles = ViewModelSpecHelper.getInitialTitle(from: subject.secondaryButtonTitleText)
                    }
                    it("should produce 1 output: `Lap`") {
                        expect(titles).to(equal(["Lap"]))
                    }
                }
                
                context("when receiving input from primary button") {
                    beforeEach {
                        let testInput = {
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                        }
                        
                        titles = ViewModelSpecHelper.getTitles(from: subject.secondaryButtonTitleText,
                                                               basedOn: testInput)
                    }
                    it("should toggle from Lap to Reset and back to start based state of timer") {
                        expect(titles).to(equal(["Lap",
                                                 "Lap",
                                                 "Reset",
                                                 "Lap",
                                                 "Reset"]))
                    }
                }
                
                context("when timer has started and secondary button receive inputs") {
                    beforeEach {
                        let testInput = {
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.secondaryButtonTapEventObserver.onNext(())
                            subject.secondaryButtonTapEventObserver.onNext(())
                        }
                        titles = ViewModelSpecHelper.getTitles(from: subject.secondaryButtonTitleText,
                                                               basedOn: testInput)
                    }
                    it("should not toggle title") {
                        expect(titles).to(equal(["Lap",
                                                 "Lap"]))
                    }
                }
                
                context("when timer is paused and secondary button receive inputs") {
                    beforeEach {
                        let testInput = {
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.secondaryButtonTapEventObserver.onNext(())
                            subject.secondaryButtonTapEventObserver.onNext(())
                        }
                        titles = ViewModelSpecHelper.getTitles(from: subject.secondaryButtonTitleText,
                                                               basedOn: testInput)
                    }
                    it("should toggle title") {
                        expect(titles).to(equal(["Lap",
                                                 "Lap",
                                                 "Reset",
                                                 "Lap"]))
                    }
                }
            }
        }
    }
}

struct ViewModelSpecHelper {
    typealias Input = (()-> Void)
    typealias TitleStream = Observable<String>
    static func getTitles(from stream: TitleStream,
                          basedOn input: @escaping Input,
                          disposeBag: DisposeBag = DisposeBag()) -> [String] {
        return ObservableHelper
            .events(from: stream,
                    disposeBag: disposeBag,
                    executeBlock: input)
            .map({$0.value.element})
            .compactMap({ $0 })
    }
    static func getInitialTitle(from stream: TitleStream,
                                disposeBag: DisposeBag = DisposeBag()) -> [String] {
        return ObservableHelper
            .events(from: stream,
                    disposeBag: disposeBag,
                    executeBlock: nil)
            .map({$0.value.element})
            .compactMap({ $0 })
    }
}
