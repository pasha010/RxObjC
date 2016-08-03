RxObjC: ReactiveX for Objective-C
=================================
[![Build Status](https://travis-ci.org/pasha010/RxObjC.svg?branch=master)](https://travis-ci.org/pasha010/RxObjC)
[![Version](https://cocoapod-badges.herokuapp.com/v/RxObjC/1.0/badge.png)](https://cocoapod-badges.herokuapp.com/v/RxObjC/1.0/badge.png) [![Platform](https://cocoapod-badges.herokuapp.com/p/RxObjC/badge.png)](https://cocoapod-badges.herokuapp.com/p/$PODNAME/badge.png) [![codecov](https://codecov.io/gh/pasha010/RxObjC/branch/master/graph/badge.svg)](https://codecov.io/gh/pasha010/RxObjC) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


RxObjC is a Objective-C port of [RxSwift](https://github.com/ReactiveX/RxSwift)

Current version is 1.0 ~ 2.5 RxSwift. 

RxObjC 1.0 contains only core of rx, without RxCocoa module.


###How install
Use [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

**:warning: IMPORTANT! For tvOS support, CocoaPods `0.39` is required. :warning:**

```
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'RxObjC', '~> 1.0'
end

# RxTests and RxBlocking make the most sense in the context of unit/integration tests
target 'YOUR_TESTING_TARGET' do
    pod 'RxBlocking', '~> 2.0'
    pod 'RxTests',    '~> 2.0'
end
```

##Modules:
###RxCocoa:
soon :)

###RxBlocking: 
_(see [RxSwift/RxBlocking](https://github.com/ReactiveX/RxSwift/tree/master/RxBlocking))_
Set of blocking operators for RxObjC. These operators are mostly intended for unit/integration tests
with a couple of other special scenarios where they could be useful.
E.g.
Waiting for observable sequence to complete before exiting command line application.

###RxTests:
_(see [RxSwift/RxTests](https://github.com/ReactiveX/RxSwift/tree/master/RxTests))_
Unit testing extensions for RxObjC. This library contains mock schedulers, observables, and observers
that should make unit testing your operators easy as unit testing RxObjC built-in operators.
This library contains everything you needed to write unit tests in the following way:
```
- (void)testMap {
    RxTestScheduler *scheduler = [[RxTestScheduler alloc] initWithInitialClock:0];

    RxTestableObservable *xs = [scheduler createHotObservable:@[
            next(150, @1),
            next(210, @0),
            next(220, @1),
            next(230, @2),
            next(240, @4),
            completed(300)
    ]];

    RxTestableObserver *res = [scheduler startWithObservable:[xs map:^NSNumber *(NSNumber *o) {
        return @(o.integerValue * 2);
    }]];

    NSArray *events = @[
            next(210, @(0 * 2)),
            next(220, @(1 * 2)),
            next(230, @(2 * 2)),
            next(240, @(4 * 2)),
            completed(300),
    ];
    XCTAssertEqualObjects(res.events, events);

    XCTAssertEqualObjects(xs.subscriptions, @[
            Subscription(200, 300)
    ]);
}
```