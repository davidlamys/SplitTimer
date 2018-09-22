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
    
    var mockTimerLabelText = PublishSubject<String>()
    var timerLabelText: Observable<String> {
        return mockTimerLabelText.asObservable()
    }
}
