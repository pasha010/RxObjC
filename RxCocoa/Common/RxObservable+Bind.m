//
//  RxObservable(Bind)
//  RxCocoa
// 
//  Created by Pavel Malkov on 19.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxObservable+Bind.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma GCC diagnostic ignored "-Wprotocol"

@implementation NSObject (RxBind)

- (nonnull id <RxDisposable>)bindTo:(nonnull id <RxObserverType>)observer {
    return [self subscribe:observer];
}

- (nonnull id <RxDisposable>)bindToVariable:(nonnull RxVariable *)variable {
    return [self subscribeWith:^(RxEvent *event) {
       switch (event.type) {
           case RxEventTypeNext: {
               variable.value = event.element;
               break;
           }
           case RxEventTypeError: {
           #if DEBUG
               rx_fatalError([NSString stringWithFormat:@"Binding error to variable %@", event.error]);
           #else
               NSLog(@"%@", event.error);
           #endif
               break;
           }
           case RxEventTypeCompleted: {
               break;
           }
       }
    }];
}

- (nonnull id <RxDisposable>)bindToBinder:(nonnull RxBinder)binder {
    return binder(self);
}

- (nonnull id)bindToBinder:(nonnull RxBinderWithCurriedArg)binder curriedArgument:(nonnull id)curriedArgument {
    return binder(self)(curriedArgument);
}

- (nonnull id <RxDisposable>)bindNext:(void(^)(id __nullable next))onNext {
    return [self subscribeOnNext:onNext onError:^(NSError *error) {
        NSString *eString = [NSString stringWithFormat:@"Binding error: %@", error];
#if DEBUG
        rx_fatalError(eString);
#else
        NSLog(@"%@", eString);
#endif
    }];
}

@end
#pragma clang diagnostic pop