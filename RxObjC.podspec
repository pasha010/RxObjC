Pod::Spec.new do |rx_spec|
  rx_spec.name = "RxObjC"
  rx_spec.version = "1.0"
  rx_spec.summary = "RxObjC is a Objective-C implementation of Reactive Extensions"
  rx_spec.description = <<-DESC
RxObjC:
RxObjC is a Objective-C port of [RxSwift]

Like the original [Rx](https://github.com/Reactive-extensions/Rx.Net), its intention is to enable easy composition of asynchronous operations and event streams.

RxBlocking: (see [RxSwift/RxBlocking](https://github.com/ReactiveX/RxSwift/tree/master/RxBlocking))
Set of blocking operators for RxObjC. These operators are mostly intended for unit/integration tests
with a couple of other special scenarios where they could be useful.
E.g.
Waiting for observable sequence to complete before exiting command line application.

RxTests: (see [RxSwift/RxTests](https://github.com/ReactiveX/RxSwift/tree/master/RxTests))
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

```
                        DESC

  rx_spec.homepage = "https://github.com/pasha010/RxObjC"
  rx_spec.license = 'MIT'
  rx_spec.author = { "Pavel Malkov" => "mpa026@gmail.com" }
  rx_spec.source = { :git => "https://github.com/pasha010/RxObjC.git", :tag => rx_spec.version.to_s }

  rx_spec.requires_arc = true

  rx_spec.ios.deployment_target = '8.0'
  rx_spec.osx.deployment_target = '10.9'
  rx_spec.watchos.deployment_target = '2.0'
  rx_spec.tvos.deployment_target = '9.0'

  rx_spec.public_header_files = 'RxObjC/**/*.h'
  rx_spec.source_files = 'RxObjC/**/*.{h, m}'

  rx_spec.subspec 'RxBlocking' do |rx_blocking_spec|
    rx_blocking_spec.source_files = 'RxBlocking/*.{h, m}'
    rx_blocking_spec.public_header_files = 'RxBlocking/*.h'
  end

  rx_spec.subspec 'RxTests' do |rx_tests_spec|
      rx_tests_spec.source_files = 'RxTests/**/*.{h, m}'
      rx_tests_spec.public_header_files = 'RxTests/**/*.h'
      rx_tests_spec.framework = 'XCTest'
      rx_tests_spec.ios.deployment_target = '8.0'
      rx_tests_spec.osx.deployment_target = '10.9'
      rx_tests_spec.tvos.deployment_target = '9.0'
  end
end