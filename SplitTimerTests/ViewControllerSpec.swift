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
            context("Pipe UI events to view model") {
                beforeEach {
                    disposeBag = DisposeBag()
                    mockViewModel = ViewControllerSpecHelper.makeMockViewModel()
                    subject = UIViewController.make(viewController: ViewController.self)
                    _ = subject.view
                    subject.viewModel = mockViewModel
                }
                context("When primary button is pressed") {
                    var events: [Recorded<Event<Void>>]!
                    beforeEach {
                        events = ObservableHelper
                            .events(from: mockViewModel.input.primaryButtonTapEventObserver,
                                    disposeBag: disposeBag,
                                    executeBlock: {
                                        subject.primaryButton.sendActions(for: .touchUpInside)
                        })
                    }
                    it("ViewModel should receive input") {
                        expect(events.count).to(be(1))
                    }
                }
            }
            
            context("Reacting to view model output") {
                context("When view model has a new output for primary button title text") {
                    beforeEach {
                        mockViewModel.mockPrimaryButtonTitleText.onNext("Hello world")
                    }
                    it("Should set primary button title") {
                        expect(subject.primaryButton.currentTitle).to(equal("Hello world"))
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
    
    var mockPrimaryButtonTitleText = PublishSubject<String>()
    var primaryButtonTitleText: Observable<String> {
        return mockPrimaryButtonTitleText.asObservable()
    }
}
