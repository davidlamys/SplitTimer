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
            var disposeBag: DisposeBag!
            
            beforeEach {
                disposeBag = DisposeBag()
                subject = ViewModel()
            }
            
            context("ViewModel should give correct output for Primary Button Text") {
                
                context("Initial value") {
                    var titles: [String]!
                    
                    beforeEach {
                        titles = ObservableHelper
                            .events(from: subject.primaryButtonTitleText,
                                    disposeBag: disposeBag,
                                    executeBlock: nil)
                            .map({$0.value.element})
                            .compactMap({ $0 })
                        
                    }
                    it("Output should be `Start`") {
                        expect(titles.count).to(be(1))
                        expect(titles.last).to(be("Start"))
                    }
                }
                
                context("Should toggle from Start to Stop and back to start based on number of taps", {
                    var titles: [String]!
                    
                    beforeEach {
                        let testInput = {
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                            subject.primaryButtonTapEventObserver.onNext(())
                        }
                        
                        titles = ObservableHelper
                            .events(from: subject.primaryButtonTitleText,
                                    disposeBag: disposeBag,
                                    executeBlock: testInput)
                            .map({$0.value.element})
                            .compactMap({ $0 })
                        
                    }
                    it("Output should be `Start`") {
                        expect(titles.count).to(be(5))
                        expect(titles[0]).to(be("Start"))
                        expect(titles[1]).to(be("Stop"))
                        expect(titles[2]).to(be("Start"))
                        expect(titles[3]).to(be("Stop"))
                        expect(titles[4]).to(be("Start"))
                    }
                })
            }
        }
    }
}
