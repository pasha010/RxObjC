//
//  RxOperationQueueScheduler
//  RxObjC
// 
//  Created by Pavel Malkov on 15.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxOperationQueueScheduler.h"
#import "RxCompositeDisposable.h"
#import "RxAnonymousDisposable.h"


@implementation RxOperationQueueScheduler

- (nonnull instancetype)initWithOperationQueue:(nonnull NSOperationQueue *)operationQueue {
    self = [super init];
    if (self) {
        _operationQueue = operationQueue;
    }
    return self;
}

- (nonnull id <RxDisposable>)schedule:(nullable RxStateType)state action:(nonnull id <RxDisposable> (^)(RxStateType __nullable))action {
    RxCompositeDisposable *compositeDisposable = [[RxCompositeDisposable alloc] init];
    
    @weakify(compositeDisposable);

    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        @strongify(compositeDisposable);
        if (compositeDisposable.disposed) {
            return;
        }
        id <RxDisposable> disposable = action(state);
        [compositeDisposable addDisposable:disposable];
    }];

    [_operationQueue addOperation:operation];

    [compositeDisposable addDisposable:[RxAnonymousDisposable create:^{
        [operation cancel];
    }]];

    return compositeDisposable;
}

@end