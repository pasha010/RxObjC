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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NSObject (RxDistinctUntilChanged)

- (nonnull RxObservable *)distinctUntilChanged {
    return [self distinctUntilChanged:^id(id o) {
        return o;
    } comparer:^BOOL(id lhs, id rhs) {
        return [lhs isEqual:rhs];
    }];
}

- (nonnull RxObservable *)distinctUntilChangedWithKeySelector:(id (^)(id))keySelector {
    return [self distinctUntilChanged:keySelector comparer:^BOOL(id lhs, id rhs) {
        return [lhs isEqual:rhs];
    }];
}

- (nonnull RxObservable *)distinctUntilChangedWithComparer:(BOOL(^)(id lhs, id rhs))comparer {
    return [self distinctUntilChanged:^id(id o) {
        return o;
    } comparer:comparer];
}

- (nonnull RxObservable *)distinctUntilChanged:(id(^)(id))keySelector comparer:(BOOL(^)(id lhs, id rhs))comparer {
    return [[RxDistinctUntilChanged alloc] initWithSource:[self asObservable] keySelector:keySelector comparer:comparer];
}

@end

@implementation NSObject (RxDoOn)

- (nonnull RxObservable *)doOn:(void (^)(RxEvent *))eventHandler {
    return [[RxDo alloc] initWithSource:[self asObservable] eventHandler:eventHandler];
}

- (nonnull RxObservable *)doOn:(nullable void (^)(id value))onNext onError:(nullable void (^)(NSError *))onError onCompleted:(nullable void (^)())onCompleted {
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

- (nonnull RxObservable *)doOnNext:(void (^)(id value))onNext {
    return [self doOn:onNext onError:nil onCompleted:nil];
}

- (nonnull RxObservable *)doOnError:(void (^)(NSError *))onError {
    return [self doOn:nil onError:onError onCompleted:nil];
}

- (RxObservable *)doOnCompleted:(void (^)())onCompleted {
    return [self doOn:nil onError:nil onCompleted:onCompleted];
}

@end

@implementation NSObject (RxStartWith)

- (nonnull RxObservable *)startWith:(nonnull NSArray *)elements {
    return [[RxStartWith alloc] initWithSource:[self asObservable] elements:elements];
}

@end

@implementation NSObject (RxRetry)

- (nonnull RxObservable *)retry {
    return [[RxCatchSequence alloc] initWithSources:[[RxInfiniteSequence alloc] initWithRepeatedValue:[self asObservable]]];
}

- (nonnull RxObservable *)retry:(NSUInteger)maxAttemptCount {
    NSMutableArray<RxObservable *> *array = [NSMutableArray arrayWithCapacity:maxAttemptCount];
    for (NSUInteger i = 0; i < maxAttemptCount; i++) {
        [array addObject:[self asObservable]];
    }
    return [[RxCatchSequence alloc] initWithSources:[array objectEnumerator]];
}

- (nonnull RxObservable *)retryWhen:(nonnull id <RxObservableType>(^)(RxObservable<NSError *> *))notificationHandler {
    return [[RxRetryWhenSequence alloc] initWithSources:[[RxInfiniteSequence alloc] initWithRepeatedValue:[self asObservable]]
                                    notificationHandler:notificationHandler];
}

@end

@implementation NSObject (RxScan)

- (nonnull RxObservable *)scan:(nonnull id)seed accumulator:(id __nonnull(^)(id __nonnull, id __nonnull))accumulator {
    return [[RxScan alloc] initWithSource:[self asObservable] seed:seed accumulator:accumulator];
}

@end

#pragma clang diagnostic pop