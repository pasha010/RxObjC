//
//  RxDelegateProxyType
//  RxObjC
// 
//  Created by Pavel Malkov on 05.09.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxDelegateProxyType.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"

@implementation NSObject (RxDelegateProxyType)

+ (nonnull id <RxDelegateProxyType>)proxyForObject:(nonnull id)object {
    [RxMainScheduler ensureExecutingOnScheduler];
    id maybeProxy = [self assignedProxyFor:object];
    
    id proxy;
    
    if (!maybeProxy) {
        proxy = [self createProxyForObject:object];
        [self assignProxy:proxy toObject:object];
        NSAssert([self assignedProxyFor:object] == proxy, @"[NSObject assignedProxyFor:object] == proxy");
    } else {
        proxy = maybeProxy;
    }

    id currentDelegate = [self currentDelegateFor:object];

    if (currentDelegate != proxy) {
        [proxy setForwardToDelegate:currentDelegate retainDelegate:NO];
        [self setCurrentDelegate:proxy toObject:object];
        NSAssert([self currentDelegateFor:object] == proxy, @"[NSObject currentDelegateFor:object] == proxy");
        NSAssert([proxy forwardToDelegate] == currentDelegate, @"[proxy forwardToDelegate] == currentDelegate");
    }
    return proxy;
}

+ (nonnull id <RxDisposable>)installForwardDelegate:(nonnull id)forwardDelegate
                                     retainDelegate:(BOOL)retainDelegate
                                   onProxyForObject:(nonnull id)object {
    
    @weakify(forwardDelegate);

    id <RxDelegateProxyType> proxy = [self proxyForObject:object];

    NSString *s = [NSString stringWithFormat:
            @"This is a feature to warn you that there is already a delegate (or data source) set somewhere previously. The action you are trying to perform will clear that delegate (data source) and that means that some of your features that depend on that delegate (data source) being set will likely stop working.\n"
            "If you are ok with this, try to set delegate (data source) to `nil` in front of this operation.\n"
            "This is the source object value: (%@) \n"
            "This this the original delegate (data source) value: %@ \n"
            "Hint: Maybe delegate was already set in xib or storyboard and now it's being overwritten in code.\n", object, [proxy forwardToDelegate]];
    NSAssert([proxy forwardToDelegate] == nil, s);

    [proxy setForwardToDelegate:forwardDelegate retainDelegate:retainDelegate];

    // refresh properties after delegate is set
    // some views like UITableView cache `respondsToSelector`
    [self setCurrentDelegate:nil toObject:object];
    [self setCurrentDelegate:proxy toObject:object];

    NSAssert([proxy forwardToDelegate] == forwardDelegate, @"Setting of delegate failed");

    return [RxAnonymousDisposable create:^{
        [RxMainScheduler ensureExecutingOnScheduler];

        @strongify(forwardDelegate);

        NSAssert(forwardDelegate == nil || [proxy forwardToDelegate] == forwardDelegate, @"Delegate was changed from time it was first set.");

        [proxy setForwardToDelegate:nil retainDelegate:retainDelegate];
    }];
}

@end

@implementation NSObject (RxSubscribeProxyDataSourceForObject)

- (nonnull id <RxDisposable>)subscribeProxyDataSourceForObject:(nonnull id)object
                                                    dataSource:(nonnull id)dataSource
                                              retainDataSource:(BOOL)retainDataSource
                                                       binding:(void(^)(id <RxDelegateProxyType>, RxEvent *))binding {

    id proxy = [[self class] proxyForObject:object];

    id <RxDisposable> disposable = [[self class] installForwardDelegate:dataSource retainDelegate:retainDataSource onProxyForObject:object];

    id <RxDisposable> subscription = [[[self asObservable]
            // source can never end, otherwise it would release the subscriber
            concatWith:[RxObservable never]]
            subscribeWith:^(RxEvent *event) {
                [RxMainScheduler ensureExecutingOnScheduler];
                
                if (object) {
                    NSAssert(proxy == [[self class] currentDelegateFor:object], @"Proxy changed");
                }
                
                binding(proxy, event);
                
                if (event.type == RxEventTypeError) {
                    rx_bindingErrorToInterface(event.error);
                    [disposable dispose];
                } else if (event.type == RxEventTypeCompleted) {
                    [disposable dispose];
                }
            }];
    
    return [RxStableCompositeDisposable createDisposable1:subscription disposable2:disposable];
}

@end

#pragma clang diagnostic pop