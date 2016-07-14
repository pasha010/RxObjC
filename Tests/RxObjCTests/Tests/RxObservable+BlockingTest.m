//
//  RxObservable+BlockingTest.m
//  RxObjC
//
//  Created by Pavel Malkov on 10.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "RxTest.h"

@interface RxObservableBlockingTest : RxTest

@end

@implementation RxObservableBlockingTest
@end

@implementation RxObservableBlockingTest (ToArray)

- (void)testToArray_empty {
    XCTAssert([[[[RxObservable empty] toBlocking] blocking_toArray] isEqualToArray:@[]]);
}

- (void)testToArray_return {
    XCTAssert([[[[RxObservable just:@42] toBlocking] blocking_toArray] isEqualToArray:@[@42]]);
}
/*
    func testToArray_return() {
        XCTAssert(try! Observable.just(42).toBlocking().toArray() == [42])
    }
    
    func testToArray_fail() {
        do {
            try Observable<Int>.error(testError).toBlocking().toArray()
            XCTFail("It should fail")
        }
        catch let e {
            XCTAssertErrorEqual(e, testError)
        }
    }
    
    func testToArray_someData() {
        XCTAssert(try! Observable.of(42, 43, 44, 45).toBlocking().toArray() == [42, 43, 44, 45])
    }
    
    func testToArray_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)
        
        let array = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(10)
            .toBlocking()
            .toArray()
        
        XCTAssert(array == Array(0..<10))
    }

    func testToArray_independent() {
        for i in 0 ..< 10 {
            let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)

            func operation1()->Observable<Int>{
                return Observable.of(1, 2).subscribeOn(scheduler)
            }

            let a = try! operation1().toBlocking().toArray()
            let b = try! operation1().toBlocking().toArray()
            let c = try! operation1().toBlocking().toArray()
            let d = try! operation1().toBlocking().toArray()

            XCTAssertEqual(a, [1, 2])
            XCTAssertEqual(b, [1, 2])
            XCTAssertEqual(c, [1, 2])
            XCTAssertEqual(d, [1, 2])
        }
    }
 */
@end
