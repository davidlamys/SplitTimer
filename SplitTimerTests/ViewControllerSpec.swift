//
//  ViewControllerSpec.swift
//  SplitTimerTests
//
//  Created by David Lam on 22/9/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import Nimble
import Quick
import RxSwift
import RxTest

@testable import SplitTimer

//swiftlint:disable function_body_length
final class ViewControllerSpec: QuickSpec {
    override func spec() {
        describe("View controller spec") {
            var subject: ViewController!
            var mockViewModel: MockViewModel!
            var disposeBag: DisposeBag!

            beforeEach {
                disposeBag = DisposeBag()
                mockViewModel = ViewControllerSpecHelper.makeMockViewModel()
                subject = UIViewController.make(viewController: ViewController.self)
                _ = subject.view
                subject.viewModel = mockViewModel
            }

            context("Pipe UI events to view model") {
                context("when primary button is pressed") {
                    var events: [Recorded<Event<Void>>]!
                    beforeEach {
                        events = ObservableHelper
                            .events(from: mockViewModel.input.primaryButtonTapEventObserver,
                                    disposeBag: disposeBag,
                                    executeBlock: {
                                        subject.primaryButton.sendActions(for: .touchUpInside)
                        })
                    }
                    it("should send input to view model") {
                        expect(events.count).to(equal(1))
                    }
                }
                context("when secondary button is pressed") {
                    var events: [Recorded<Event<Void>>]!
                    beforeEach {
                        events = ObservableHelper
                            .events(from: mockViewModel.input.secondaryButtonTapEventObserver,
                                    disposeBag: disposeBag,
                                    executeBlock: {
                                        subject.secondaryButton.sendActions(for: .touchUpInside)
                            })
                    }
                    it("should send input to view model") {
                        expect(events.count).to(equal(1))
                    }
                }

                context("when segment control is tapped") {
                    var events: [Recorded<Event<Int>>]!
                    beforeEach {
                        events = ObservableHelper
                            .events(from: mockViewModel.input.displaySegmentControlObserver, disposeBag: disposeBag, executeBlock: {
                                subject.displayModeSegmentControl.selectedSegmentIndex = 1
                                subject.displayModeSegmentControl.sendActions(for: .valueChanged)
                                subject.displayModeSegmentControl.selectedSegmentIndex = 1
                                subject.displayModeSegmentControl.sendActions(for: .valueChanged)
                                subject.displayModeSegmentControl.selectedSegmentIndex = 1
                                subject.displayModeSegmentControl.sendActions(for: .valueChanged)
                                subject.displayModeSegmentControl.selectedSegmentIndex = 2
                                subject.displayModeSegmentControl.sendActions(for: .valueChanged)

                            })
                    }
                    it("should send input to view model when there is distinct changes") {
                        expect(events.count) == 2
                    }
                }
            }

            context("Reacting to view model output") {
                context("when view model has a new output for primary button title text") {
                    beforeEach {
                        mockViewModel.mockPrimaryButtonTitleText.onNext("Hello world")
                    }
                    it("should set primary button title") {
                        expect(subject.primaryButton.currentTitle) == "Hello world"
                    }
                }
                context("when view model has a new output for secondary button title text") {
                    beforeEach {
                        mockViewModel.mockSecondaryButtonTitleText.onNext("Good bye world")
                    }
                    it("should set secondary button title") {
                        expect(subject.secondaryButton.currentTitle) == "Good bye world"
                    }
                }
                context("when view model has a new output for timer label text") {
                    beforeEach {
                        mockViewModel.mockTimerLabelText.onNext("25:25:25")
                    }
                    it("should set title") {
                        expect(subject.timerLabel.text) == "25:25:25"
                    }
                }
                context("when view model sends signal to enable secondary button") {
                    beforeEach {
                        subject.secondaryButton.isEnabled = false
                        mockViewModel.mockSecondaryButtonEnable.onNext(true)
                    }
                    it("should enable secondary button") {
                        expect(subject.secondaryButton.isEnabled).to(beTrue())
                    }
                }
                context("when view model sends signal to disable secondary button") {
                    beforeEach {
                        subject.secondaryButton.isEnabled = true
                        mockViewModel.mockSecondaryButtonEnable.onNext(false)
                    }
                    it("should disable secondary button") {
                        expect(subject.secondaryButton.isEnabled).to(beFalse())
                    }
                }
                context("when view model sends an array of 2 lapModels") {
                    // data source should be sorted with the latest lap in first element
                    var cell0: UITableViewCell?
                    var cell1: UITableViewCell?
                    let indexPath0 = IndexPath(item: 0, section: 0)
                    let indexPath1 = IndexPath(item: 1, section: 0)
                    let sampleLapModels = [LapModel(lapTime: 5, splitTime: 15), // lap 2
                                           LapModel(lapTime: 10, splitTime: 10)]// lap 1
                    beforeEach {
                        mockViewModel.mockDisplayMode.onNext(.both)
                        mockViewModel.mockLapModels.onNext(sampleLapModels)
                        cell0 = subject.tableView.cellForRow(at: indexPath0)
                        cell1 = subject.tableView.cellForRow(at: indexPath1)
                    }
                    it("should increase table view count") {
                        expect(subject.tableView.numberOfRows(inSection: 0)) == 2
                    }

                    context("when user tap on a `split only`") {
                        beforeEach {
                            mockViewModel.mockDisplayMode.onNext(.splitOnly)
                            mockViewModel.mockLapModels.onNext(sampleLapModels)
                            cell0 = subject.tableView.cellForRow(at: indexPath0)
                            cell1 = subject.tableView.cellForRow(at: indexPath1)
                        }
                        it("should set the cells correctly") {
                            expect(cell0?.textLabel?.text) == "Lap 2"
                            expect(cell0?.detailTextLabel?.text) == "00:01.5"
                            expect(cell1?.textLabel?.text) == "Lap 1"
                            expect(cell1?.detailTextLabel?.text) == "00:01.0"
                        }
                    }
                    context("when user tap on a `lap only`") {
                        beforeEach {
                            mockViewModel.mockDisplayMode.onNext(.lapOnly)
                            mockViewModel.mockLapModels.onNext(sampleLapModels)
                            cell0 = subject.tableView.cellForRow(at: indexPath0)
                            cell1 = subject.tableView.cellForRow(at: indexPath1)
                        }
                        it("should set the cells correctly") {
                            expect(cell0?.textLabel?.text) == "Lap 2"
                            expect(cell0?.detailTextLabel?.text) == "00:00.5"
                            expect(cell1?.textLabel?.text) == "Lap 1"
                            expect(cell1?.detailTextLabel?.text) == "00:01.0"
                        }
                    }
                    context("when user tap on a `both`") {
                        beforeEach {
                            subject.displayModeSegmentControl.selectedSegmentIndex = 2
                            subject.displayModeSegmentControl.sendActions(for: .valueChanged)
                            cell0 = subject.tableView.cellForRow(at: indexPath0)
                            cell1 = subject.tableView.cellForRow(at: indexPath1)
                        }
                        it("should set the cells correctly") {
                            expect(cell0?.textLabel?.text) == "00:01.5"
                            expect(cell0?.detailTextLabel?.text) == "00:00.5"
                            expect(cell1?.textLabel?.text) == "00:01.0"
                            expect(cell1?.detailTextLabel?.text) == "00:01.0"
                        }
                    }
                }
            }
        }
    }
}

struct ViewControllerSpecHelper {
    static func makeMockViewModel() -> MockViewModel {
        return MockViewModel()
    }
}

class MockViewModel: ViewModelType, ViewModelInputType, ViewModelOutputType {

    var input: ViewModelInputType { return self }
    var output: ViewModelOutputType { return self }
    var primaryButtonTapEventObserver = PublishSubject<Void>()
    var secondaryButtonTapEventObserver = PublishSubject<Void>()
    var displaySegmentControlObserver = PublishSubject<Int>()

    var mockPrimaryButtonTitleText = PublishSubject<String>()
    var primaryButtonTitleText: Observable<String> {
        return mockPrimaryButtonTitleText.asObservable()
    }

    var mockSecondaryButtonTitleText = PublishSubject<String>()
    var secondaryButtonTitleText: Observable<String> {
        return mockSecondaryButtonTitleText.asObservable()
    }

    var mockSecondaryButtonEnable = PublishSubject<Bool>()
    var secondaryButtonEnabled: Observable<Bool> {
        return mockSecondaryButtonEnable.asObservable()
    }

    var mockTimerLabelText = PublishSubject<String>()
    var timerLabelText: Observable<String> {
        return mockTimerLabelText.asObservable()
    }

    var mockLapModels = PublishSubject<[LapModel]>()
    var lapModels: Observable<[LapModel]> {
        return mockLapModels
    }

    var mockDisplayMode = PublishSubject<DisplayMode>()
    var displayMode: Observable<DisplayMode> {
        return mockDisplayMode
    }
}
