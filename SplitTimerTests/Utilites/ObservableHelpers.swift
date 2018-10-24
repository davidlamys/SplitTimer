//
//  ObservableHelpers.swift
//  SplitTimerTests
//
//  Created by David Lam on 22/9/18.
//  Copyright © 2018 David Lam. All rights reserved.
//

import RxSwift
import RxTest

struct ObservableHelper {

    static func events<T>(from observable: Observable<T>,
                          disposeBag: DisposeBag,
                          executeBlock: (() -> Void)?) -> [Recorded<Event<T>>] {
        let testScheduler = TestScheduler(initialClock: 0)
        let testObserver = testScheduler.createObserver(T.self)

        observable
            .bind(to: testObserver)
            .disposed(by: disposeBag)

        if let executeBlock = executeBlock { executeBlock() }
        return testObserver.events
    }
}
