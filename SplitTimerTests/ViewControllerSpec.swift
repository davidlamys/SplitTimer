//
//  ViewControllerSpec.swift
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
                        expect(events.count).to(be(1))
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
                        expect(events.count).to(be(1))
                    }
                }
            }
            
            context("Reacting to view model output") {
                context("when view model has a new output for primary button title text") {
                    beforeEach {
                        mockViewModel.mockPrimaryButtonTitleText.onNext("Hello world")
                    }
                    it("should set primary button title") {
                        expect(subject.primaryButton.currentTitle).to(equal("Hello world"))
                    }
                }
                context("when view model has a new output for secondary button title text") {
                    beforeEach {
                        mockViewModel.mockSecondaryButtonTitleText.onNext("Good bye world")
                    }
                    it("should set secondary button title") {
                        expect(subject.secondaryButton.currentTitle).to(equal("Good bye world"))
                    }
                }
                context("when view model has a new output for timer label text") {
                    beforeEach {
                        mockViewModel.mockTimerLabelText.onNext("25:25:25")
                    }
                    it("should set title") {
                        expect(subject.timerLabel.text).to(equal("25:25:25"))
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
                context("when view model sends an array of 2 cellModels") {
                    var cell0: UITableViewCell?
                    var cell1: UITableViewCell?
                    beforeEach {
                        mockViewModel.mockCellModels.onNext([CellModel(lapTime: 10, splitTime: 10),
                                                             CellModel(lapTime: 5, splitTime: 15)])
                        let indexPath0 = IndexPath(item: 0, section: 0)
                        cell0 = subject.tableView.cellForRow(at: indexPath0)
                        
                        let indexPath1 = IndexPath(item: 1, section: 0)
                        cell1 = subject.tableView.cellForRow(at: indexPath1)
                    }
                    it("should increase table view count") {
                        expect(subject.tableView.numberOfRows(inSection: 0)).to(equal(2))
                    }
                    it("should set the cells correctly") {
                        expect(cell0?.textLabel?.text).to(equal("00:01.0"))
                        expect(cell0?.detailTextLabel?.text).to(equal("00:01.0"))
                        expect(cell1?.textLabel?.text).to(equal("00:00.5"))
                        expect(cell1?.detailTextLabel?.text).to(equal("00:01.5"))
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

    var mockCellModels = PublishSubject<[CellModel]>()
    var cellModels: Observable<[CellModel]> {
        return mockCellModels
    }
}
