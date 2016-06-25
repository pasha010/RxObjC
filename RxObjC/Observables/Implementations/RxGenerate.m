//
//  RxGenerate
//  RxObjC
// 
//  Created by Pavel Malkov on 25.06.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxGenerate.h"
#import "RxImmediateSchedulerType.h"
#import "RxSink.h"

@interface RxGenerateSink<S, O : id<RxObserverType>> : RxSink <O>

@end

@implementation RxGenerateSink {
    RxGenerate *__nonnull _parent;
    id __nonnull _state;
}

- (instancetype)initWithParent:(RxGenerate *)parent observer:(nonnull id <RxObserverType>)observer {
    self = [super initWithObserver:observer];
    if (self) {
        _parent = parent;
        _state = parent->_initialState;
    }
    return self;
}

- (nonnull id <RxDisposable>)run {
    NSObject <RxImmediateSchedulerType> *scheduler = _parent->_scheduler;
    @weakify(self);
    return [scheduler scheduleRecursive:@(YES) action:^(NSNumber *isFirstNumber, void (^recurse)(id)) {
        @strongify(self);
        @try {
            BOOL isFirst = isFirstNumber.boolValue;
            if (!isFirst) {
                self->_state = self->_parent->_iterate(self->_state);
            }
            
            if (self->_parent->_condition(self->_state)) {
                id result = self->_parent->_resultSelector(self->_state);
                [self forwardOn:[RxEvent next:result]];
                
                recurse(@NO);
            } else {
                [self forwardOn:[RxEvent completed]];
                [self dispose];
            }
        }
        @catch (id e) {
            NSError *error = e;
            if ([e isKindOfClass:[NSException class]]) {
                NSException *exception = e;
                error = [NSError errorWithDomain:[NSString stringWithFormat:@"RxGenerateSink + %@", exception.name]
                                            code:[self hash]
                                        userInfo:exception.userInfo];
            }
            [self forwardOn:[RxEvent error:error]];
            [self dispose];
        }
    }];
}

@end

@implementation RxGenerate

- (nonnull instancetype)initWithInitialState:(nonnull id)initialState 
                                   condition:(BOOL (^)(id))condition 
                                     iterate:(id (^)(id))iterate 
                              resultSelector:(id (^)(id))resultSelector 
                                   scheduler:(nonnull id <RxImmediateSchedulerType>)scheduler {
    self = [super init];
    if (self) {
        _initialState = initialState;
        _condition = condition;
        _iterate = iterate;
        _resultSelector = resultSelector;
        _scheduler = scheduler;
    }
    return self;
}

- (nonnull id <RxDisposable>)subscribe:(nonnull id <RxObserverType>)observer {
    RxGenerateSink *sink = [[RxGenerateSink alloc] initWithParent:self observer:observer];
    sink.disposable = [sink run];
    return sink;
}

@end