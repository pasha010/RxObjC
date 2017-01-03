//
//  RxObservable(Single)
//  RxObjC
// 
//  Created by Pavel Malkov on 28.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Single.h"
#import "RxDistinctUntilChanged.h"
#import "RxDo.h"
#import "RxStartWith.h"
#import "RxCatch.h"
#import "RxInfiniteSequence.h"
#import "RxRetryWhen.h"
#import "RxScan.h"

@implementation RxObservable (DistinctUntilChanged)

- (nonnull RxObservable<id> *)distinctUntilChanged {
    return [self distinctUntilChanged:^id(id o) {
        return o;
    }                        comparer:^BOOL(id lhs, id rhs) {
        return [lhs isEqual:rhs];
    }];
}

- (nonnull RxObservable<id> *)distinctUntilChangedWithKeySelector:(id (^)(id))keySelector {
    return [self distinctUntilChanged:keySelector comparer:^BOOL(id lhs, id rhs) {
        return [lhs isEqual:rhs];
    }];
}

- (nonnull RxObservable<id> *)distinctUntilChangedWithComparer:(BOOL(^)(id lhs, id rhs))comparer {
    return [self distinctUntilChanged:^id(id o) {
        return o;
    }                        comparer:comparer];
}

- (nonnull RxObservable<id> *)distinctUntilChanged:(id(^)(id))keySelector comparer:(BOOL(^)(id lhs, id rhs))comparer {
    return [[RxDistinctUntilChanged alloc] initWithSource:[self asObservable] keySelector:keySelector comparer:comparer];
}

@end

@implementation RxObservable (DoOn)

- (nonnull RxObservable<id> *)doOn:(void (^)(RxEvent<id> *))eventHandler {
    return [[RxDo alloc] initWithSource:[self asObservable] eventHandler:eventHandler];
}

- (nonnull RxObservable<id> *)doOn:(nullable void (^)(id value))onNext onError:(nullable void (^)(NSError *))onError onCompleted:(nullable void (^)())onCompleted {
    return [self doOn:^(RxEvent *event) {
        switch (event.type) {
            case RxEventTypeNext: {
                if (onNext) {
                    onNext(event.element);
                }
                break;
            }
            case RxEventTypeError: {
                if (onError) {
                    onError(event.error);
                }
                break;
            }
            case RxEventTypeCompleted: {
                if (onCompleted) {
                    onCompleted();
                }
                break;
            }
        }
    }];
}

- (nonnull RxObservable<id> *)doOnNext:(void (^)(id value))onNext {
    return [self doOn:onNext onError:nil onCompleted:nil];
}

- (nonnull RxObservable<id> *)doOnError:(void (^)(NSError *))onError {
    return [self doOn:nil onError:onError onCompleted:nil];
}

- (nonnull RxObservable<id> *)doOnCompleted:(void (^)())onCompleted {
    return [self doOn:nil onError:nil onCompleted:onCompleted];
}

@end

@implementation RxObservable (StartWith)

- (nonnull RxObservable<id> *)startWithElements:(nonnull NSArray<id> *)elements {
    return [[RxStartWith alloc] initWithSource:[self asObservable] elements:elements];
}

- (nonnull RxObservable<id> *)startWith:(nonnull id)element {
    if ([element isKindOfClass:[NSArray class]]) {
        return [self startWithElements:element];
    }
    return [self startWithElements:@[element]];
}

@end

@implementation RxObservable (Retry)

- (nonnull RxObservable<id> *)retry {
    return [[RxCatchSequence alloc] initWithSources:[[RxInfiniteSequence alloc] initWithRepeatedValue:[self asObservable]]];
}

- (nonnull RxObservable<id> *)retry:(NSUInteger)maxAttemptCount {
    NSMutableArray<RxObservable *> *array = [NSMutableArray arrayWithCapacity:maxAttemptCount];
    for (NSUInteger i = 0; i < maxAttemptCount; i++) {
        [array addObject:[self asObservable]];
    }
    return [[RxCatchSequence alloc] initWithSources:[array objectEnumerator]];
}

- (nonnull RxObservable<id> *)retryWhen:(nonnull id <RxObservableType>(^)(RxObservable<__kindof NSError *> *))notificationHandler {
    return [self retryWhen:notificationHandler customErrorClass:nil];
}

- (nonnull RxObservable<id> *)retryWhen:(nonnull id <RxObservableType>(^)(RxObservable<__kindof NSError *> *))notificationHandler
                       customErrorClass:(nullable Class)errorClass {
    return [[RxRetryWhenSequence alloc] initWithSources:[[RxInfiniteSequence alloc] initWithRepeatedValue:[self asObservable]]
                                    notificationHandler:notificationHandler
                                       customErrorClass:errorClass];
}

@end

@implementation RxObservable (Scan)

- (nonnull RxObservable<id> *)scan:(nonnull id)seed accumulator:(id __nonnull (^)(id __nonnull accumulate, id __nonnull element))accumulator {
    return [[RxScan alloc] initWithSource:[self asObservable] seed:seed accumulator:accumulator];
}

@end