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
                        titles = ViewModelSpecHelper.getInitialText(from: subject.primaryButtonTitleText)
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
                        titles = ViewModelSpecHelper.getText(from: subject.primaryButtonTitleText,
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
                        titles = ViewModelSpecHelper.getInitialText(from: subject.secondaryButtonTitleText)
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
                        
                        titles = ViewModelSpecHelper.getText(from: subject.secondaryButtonTitleText,
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
                        titles = ViewModelSpecHelper.getText(from: subject.secondaryButtonTitleText,
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
                        titles = ViewModelSpecHelper.getText(from: subject.secondaryButtonTitleText,
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
            
            // MARK: - Secondary Button Enablement
            context("Secondary button enablement") {
                var buttonState: [Bool]!
                
                context("when view model is set up initially") {
                    beforeEach {
                        buttonState = ViewModelSpecHelper.getInitialEnableState(from: subject.secondaryButtonEnabled)
                    }
                    it("should disable secondary button") {
                        expect(buttonState).to(equal([false]))
                    }
                }
                
                context("when timer is started") {
                    beforeEach {
                        let testInput = {
                            subject.primaryButtonTapEventObserver.onNext(())
                        }
                        buttonState = ViewModelSpecHelper.getEnableStates(from: subject.secondaryButtonEnabled,
                                                                          basedOn: testInput)
                    }
                    it("should toggle state") {
                        expect(buttonState).to(equal([false,
                                                      true]))
                    }
                    
                    context("when split timing is triggered") {
                        beforeEach {
                            let testInput = {
                                subject.primaryButtonTapEventObserver.onNext(())
                                subject.secondaryButtonTapEventObserver.onNext(())
                                subject.secondaryButtonTapEventObserver.onNext(())
                                subject.secondaryButtonTapEventObserver.onNext(())
                                subject.secondaryButtonTapEventObserver.onNext(())
                            }
                            buttonState = ViewModelSpecHelper.getEnableStates(from: subject.secondaryButtonEnabled,
                                                                              basedOn: testInput)
                        }
                        it("should toggle state") {
                            expect(buttonState).to(equal([false,
                                                          true]))
                        }
                    }
                    
                }
                
                context("when timer is paused") {
                    beforeEach {
                        let testInput = {
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                        }
                        buttonState = ViewModelSpecHelper.getEnableStates(from: subject.secondaryButtonEnabled,
                                                                     basedOn: testInput)
                    }
                    it("should toggle state") {
                        expect(buttonState).to(equal([false,
                                                      true]))
                    }
                    
                    context("when timer is resumed") {
                        beforeEach {
                            let testInput = {
                                subject.primaryButtonTapEventObserver.onNext(())
                                subject.primaryButtonTapEventObserver.onNext(())
                                subject.primaryButtonTapEventObserver.onNext(())
                            }
                            buttonState = ViewModelSpecHelper.getEnableStates(from: subject.secondaryButtonEnabled,
                                                                              basedOn: testInput)
                        }
                        it("should toggle state") {
                            expect(buttonState).to(equal([false,
                                                          true]))
                        }
                    }
                    
                    context("when timer is cleared") {
                        beforeEach {
                            let testInput = {
                                subject.primaryButtonTapEventObserver.onNext(())
                                subject.primaryButtonTapEventObserver.onNext(())
                                subject.secondaryButtonTapEventObserver.onNext(())
                            }
                            buttonState = ViewModelSpecHelper.getEnableStates(from: subject.secondaryButtonEnabled,
                                                                              basedOn: testInput)
                        }
                        it("should toggle state") {
                            expect(buttonState).to(equal([false,
                                                          true,
                                                          false]))
                        }
                    }
                    
                }
                
            }
            
            // MARK: Timer text generation
            context("Generating text for timer") {
                var texts: [String]!
                context("when user started and paused the timer after 2 ticks") {
                    beforeEach {
                        let timerSimulator = PublishSubject<Void>() // 1 tick == 1 millisecond
                        let stateStream = PublishSubject<TimerState>()
                        subject = ViewModel(timer: timerSimulator, timerStateStream: stateStream)
                        texts = ViewModelSpecHelper
                            .getText(from: subject.timerLabelText,
                                     basedOn: {
                                        stateStream.onNext(.started)
                                        timerSimulator.onNext(())
                                        timerSimulator.onNext(())
                                        stateStream.onNext(.paused)
                                        timerSimulator.onNext(())
                            })
                    }
                    it("should generate an array of 2 texts only") {
                        expect(texts).to(equal(["00:00.1", "00:00.2"]))
                    }
                }
                
                context("when user start, paused after 2 ticks, and resume after 2 ticks") {
                    beforeEach {
                        let timerSimulator = PublishSubject<Void>() // 1 tick == 1 millisecond
                        let stateStream = PublishSubject<TimerState>()
                        subject = ViewModel(timer: timerSimulator, timerStateStream: stateStream)
                        texts = ViewModelSpecHelper
                            .getText(from: subject.timerLabelText,
                                     basedOn: {
                                        stateStream.onNext(.started)
                                        timerSimulator.onNext(())
                                        timerSimulator.onNext(())
                                        stateStream.onNext(.paused)
                                        timerSimulator.onNext(())
                                        timerSimulator.onNext(())
                                        stateStream.onNext(.started)
                                        timerSimulator.onNext(())
                            })
                    }
                    it("should generate an array of 3 texts ") {
                        expect(texts).to(equal(["00:00.1", "00:00.2", "00:00.3"]))
                    }
                }
                
                context("when user start, paused after 2 ticks, and clear after 2 ticks") {
                    beforeEach {
                        let timerSimulator = PublishSubject<Void>() // 1 tick == 1 millisecond
                        let stateStream = PublishSubject<TimerState>()
                        subject = ViewModel(timer: timerSimulator, timerStateStream: stateStream)
                        texts = ViewModelSpecHelper
                            .getText(from: subject.timerLabelText,
                                     basedOn: {
                                        stateStream.onNext(.started)
                                        timerSimulator.onNext(())
                                        timerSimulator.onNext(())
                                        stateStream.onNext(.paused)
                                        timerSimulator.onNext(())
                                        timerSimulator.onNext(())
                                        stateStream.onNext(.cleared)
                                        timerSimulator.onNext(())
                            })
                    }
                    it("should generate an array of 3 texts ") {
                        expect(texts).to(equal(["00:00.1", "00:00.2", "00:00.0"]))
                    }
                }
            }
            
            // MARK: - Generate text for split timings
            context("Generating text for split timings") {
                var lapTimingsTexts: [[String]]!
                context("when user started and paused the timer after 2 ticks") {
                    beforeEach {
                        let timerSimulator = PublishSubject<Void>() // 1 tick == 1 millisecond
                        subject = ViewModel(timer: timerSimulator)
                        lapTimingsTexts = ViewModelSpecHelper
                            .getValues(from: subject.lapTimeTexts,
                                     basedOn: {
                                        subject.primaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        timerSimulator.onNext(())
                                        subject.primaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        subject.primaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())

                            })
                    }
                    it("should generate an array of 3 texts only") {
                        expect(lapTimingsTexts).to(equal([["00:00.1 - 00:00.1"],
                                                          ["00:00.2 - 00:00.2"],
                                                          ["00:00.3 - 00:00.3"]]))
                    }
                }
                context("when user started and split after 2 ticks and split again, and finally paused timer after 2 ticks") {
                    beforeEach {
                        let timerSimulator = PublishSubject<Void>() // 1 tick == 1 millisecond
                        subject = ViewModel(timer: timerSimulator)
                        lapTimingsTexts = ViewModelSpecHelper
                            .getValues(from: subject.lapTimeTexts,
                                       basedOn: {
                                        subject.primaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        timerSimulator.onNext(())
                                        subject.secondaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        subject.secondaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        subject.primaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                            })
                    }
                    it("should generate an array of 2 texts only") {
                        expect(lapTimingsTexts).to(equal([["00:00.1 - 00:00.1"],
                                                          ["00:00.2 - 00:00.2"],
                                                          ["00:00.0 - 00:00.2", "00:00.2 - 00:00.2"],
                                                          ["00:00.1 - 00:00.3", "00:00.2 - 00:00.2"],
                                                          ["00:00.0 - 00:00.3", "00:00.1 - 00:00.3", "00:00.2 - 00:00.2"],
                                                          ["00:00.1 - 00:00.4", "00:00.1 - 00:00.3", "00:00.2 - 00:00.2"]]))
                    }
                }
            }
            // MARK: - Generate text for split timings
            context("Generating cellModels for split timings") {
                var cellModels: [[CellModel]]!
                context("when user started and paused the timer after 2 ticks") {
                    beforeEach {
                        let timerSimulator = PublishSubject<Void>() // 1 tick == 1 millisecond
                        subject = ViewModel(timer: timerSimulator)
                        cellModels = ViewModelSpecHelper
                            .getValues(from: subject.cellModels,
                                       basedOn: {
                                        subject.primaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        timerSimulator.onNext(())
                                        subject.primaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        subject.primaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        
                            })
                    }
                    it("should generate an array of 3 cell models only") {
                        let expectedCellModels = [[CellModel(lapTime: 1, splitTime: 1)],
                                                  [CellModel(lapTime: 2, splitTime: 2)],
                                                  [CellModel(lapTime: 3, splitTime: 3)]]
                        
                        expect(cellModels).to(equal(expectedCellModels))
                    }
                }
                context("when user started and split after 2 ticks and split again, and finally paused timer after 2 ticks") {
                    beforeEach {
                        let timerSimulator = PublishSubject<Void>() // 1 tick == 1 millisecond
                        subject = ViewModel(timer: timerSimulator)
                        cellModels = ViewModelSpecHelper
                            .getValues(from: subject.cellModels,
                                       basedOn: {
                                        subject.primaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        timerSimulator.onNext(())
                                        subject.secondaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        subject.secondaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                                        subject.primaryButtonTapEventObserver.onNext(())
                                        timerSimulator.onNext(())
                            })
                    }
                    it("should generate an array of 2 texts only") {
                        let firstLap = CellModel(lapTime: 2, splitTime: 2)
                        let secondLap = CellModel(lapTime: 1, splitTime: 3)
                        let thirdLap = CellModel(lapTime: 1, splitTime: 4)
                        
                        let expectedCellModels = [[CellModel(lapTime: 1, splitTime: 1)],
                                                  [firstLap],
                                                  [CellModel(lapTime: 0, splitTime: 2), firstLap],
                                                  [secondLap, firstLap],
                                                  [CellModel(lapTime: 0, splitTime: 3), secondLap, firstLap],
                                                  [thirdLap, secondLap, firstLap]]

                        expect(cellModels).to(equal(expectedCellModels))
                    }
                }
            }
        }
    }
}

struct ViewModelSpecHelper {
    typealias Input = (()-> Void)
    typealias TitleStream = Observable<String>
    
    static func getText(from stream: TitleStream,
                        basedOn input: @escaping Input,
                        disposeBag: DisposeBag = DisposeBag()) -> [String] {
        return ObservableHelper
            .events(from: stream,
                    disposeBag: disposeBag,
                    executeBlock: input)
            .map({ $0.value.element })
            .compactMap({ $0 })
    }
    
    static func getInitialText(from stream: TitleStream,
                               disposeBag: DisposeBag = DisposeBag()) -> [String] {
        return ObservableHelper
            .events(from: stream,
                    disposeBag: disposeBag,
                    executeBlock: nil)
            .map({ $0.value.element })
            .compactMap({ $0 })
    }
    
    static func getInitialEnableState(from stream: Observable<Bool>,
                                      disposeBag: DisposeBag = DisposeBag()) -> [Bool] {
        return ObservableHelper
            .events(from: stream,
                    disposeBag: disposeBag,
                    executeBlock: nil)
            .map({ $0.value.element })
            .compactMap({ $0 })
    }
    
    static func getEnableStates(from stream: Observable<Bool>,
                                basedOn input: @escaping Input,
                                disposeBag: DisposeBag = DisposeBag()) -> [Bool] {
        return ViewModelSpecHelper.getValues(from: stream,
                                             basedOn: input)
    }
    
    static func getValues<T>(from stream: Observable<T>,
                             basedOn input: @escaping Input,
                             disposeBag: DisposeBag = DisposeBag()) -> [T] {
        return ObservableHelper
            .events(from: stream,
                    disposeBag: disposeBag,
                    executeBlock: input)
            .map({ $0.value.element })
            .compactMap({ $0 })
    }
    
    static func getInitialValue<T>(from stream: Observable<T>,
                                   disposeBag: DisposeBag = DisposeBag()) -> [T] {
        return ObservableHelper
            .events(from: stream,
                    disposeBag: disposeBag,
                    executeBlock: nil)
            .map({ $0.value.element })
            .compactMap({ $0 })
    }
}
