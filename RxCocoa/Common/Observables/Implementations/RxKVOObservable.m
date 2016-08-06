//
//  RxKVOObservable
//  RxObjC
// 
//  Created by Pavel Malkov on 03.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxKVOObservable.h"
#import "NSObject+Rx.h"
#import "RxCocoaCommon.h"

@interface RxKVOObservable ()
@property (nonnull, strong, nonatomic) id strongTarget;
@end

@implementation RxKVOObservable

- (nonnull instancetype)initWithObject:(nonnull id)target
                               keyPath:(nonnull NSString *)keyPath
                               options:(NSKeyValueObservingOptions)options
                          retainTarget:(BOOL)retainTarget{
    self = [super init];
    if (self) {
        self.target = target;
        self.keyPath = keyPath;
        self.options = options;
        self.retainTarget = retainTarget;
        if (retainTarget) {
            self.strongTarget = target;
        }
    }

    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    RxKVOObserver *kvoObserver = [[RxKVOObserver alloc] initWithParent:self callback:^(id object) {
        if ([object isKindOfClass:[NSNull class]]) {
            [observer on:[RxEvent next:nil]];
        } else {
            [observer on:[RxEvent next:object]];
        }
    }];

    return [RxAnonymousDisposable create:^{
        [kvoObserver dispose];
    }];
}

@end

#if !DISABLE_SWIZZLING

RxObservable *__nonnull rx_observeWeaklyKeyPathFor(NSObject *__nonnull target, NSString *__nonnull keyPath, NSKeyValueObservingOptions options) {
    NSArray<NSString *> *components = [[keyPath componentsSeparatedByString:@"."] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary<NSString *, id> *bindings) {
        return ![evaluatedObject isEqualToString:@"self"];
    }]];


    RxObservable *observable = [rx_observeWeaklyKeyPathSectionsFor(target, components, options) finishWithNilWhenDealloc:target];

    if ((options & NSKeyValueObservingOptionInitial) != 0) {
        return observable;
    } else {
        return [observable skip:1];
    }
}

BOOL rx_isWeakProperty(NSString *__nonnull propertyRuntimeInfo) {
    return [propertyRuntimeInfo rangeOfString:@",W,"].location != NSNotFound;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"

@implementation NSObject (RxFinishWhenDealloc)

- (nonnull RxObservable *)finishWithNilWhenDealloc:(nonnull NSObject *)target {
    RxObservable *deallocating = target.rx_deallocating;

    return [[[deallocating
            map:^id(id __unused _) {
                return [RxObservable just:nil];
            }]
            startWith:[self asObservable]]
            switchLatest];
}

@end
#pragma clang diagnostic pop

FOUNDATION_EXTERN RxObservable *__nonnull rx_observeWeaklyKeyPathSectionsFor(NSObject *__nonnull target, NSArray<NSString *> *__nonnull keyPathSections, NSKeyValueObservingOptions options) {
    NSString *propertyName = keyPathSections.firstObject;
    NSArray<NSString *> *remainingPaths = keyPathSections.count > 1 ? [keyPathSections subarrayWithRange:NSMakeRange(1, keyPathSections.count - 1)] : nil;

    objc_property_t pProperty = class_getProperty(object_getClass(target), propertyName.UTF8String);

    if (pProperty == nil) {
        return [RxObservable error:[RxCocoaError invalidPropertyName:target propertyName:propertyName]];
    }

    char const *propertyAttributes = property_getAttributes(pProperty);

    // should dealloc hook be in place if week property, or just create strong reference because it doesn't matter
    BOOL isWeak = rx_isWeakProperty([NSString stringWithUTF8String:propertyAttributes]);

    RxKVOObservable *propertyObservable = [[RxKVOObservable alloc] initWithObject:target keyPath:propertyName options:options | NSKeyValueObservingOptionInitial retainTarget:NO];

    @weakify(target);
    return [propertyObservable flatMapLatest:^id <RxObservableConvertibleType>(id nextTarget) {
        if (!nextTarget) {
            return [RxObservable just:nil];
        }

        NSObject *nextObject = nextTarget;
        @strongify(target);

        // if target is alive, then send change
        // if it's deallocated, don't send anything
        if (!target) {
            return [RxObservable empty];
        }

        RxObservable *nextElementsObservable = keyPathSections.count == 1 ? [RxObservable just:nextTarget] : rx_observeWeaklyKeyPathSectionsFor(nextObject, remainingPaths, options);

        if (isWeak) {
            return [nextElementsObservable finishWithNilWhenDealloc:nextObject];
        }
        return nextElementsObservable;
    }];
}

#endif