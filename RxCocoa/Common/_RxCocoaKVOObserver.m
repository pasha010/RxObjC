//
//  _RxCocoaKVOObserver.m
//  RxCocoa
//
//  Created by Pavel Malkov on 19.07.16.
//  Copyright © 2016 Pavel Malkov. All rights reserved.
//

#import "_RxCocoaKVOObserver.h"

@interface _RxCocoaKVOObserver ()

@property (nonatomic, unsafe_unretained) id target;
@property (nullable, nonatomic, strong) id retainedTarget;
@property (nonnull, nonatomic, copy) NSString *keyPath;
@property (nonnull, nonatomic, copy) RxKVOCallback callback;

@end

@implementation _RxCocoaKVOObserver

- (nonnull instancetype)initWithTarget:(nonnull id)target
                          retainTarget:(BOOL)retainTarget
                               keyPath:(nonnull NSString *)keyPath
                               options:(NSKeyValueObservingOptions)options
                              callback:(nonnull RxKVOCallback)callback {
    self = [super init];
    if (self) {
        self.target = target;
        if (retainTarget) {
            self.retainedTarget = target;
        }
        self.keyPath = keyPath;
        self.callback = callback;

        [self.target addObserver:self forKeyPath:self.keyPath options:options context:nil];
    }

    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *, id> *)change
                       context:(nullable void *)context {
    @synchronized (self) {
        self.callback(change[NSKeyValueChangeNewKey]);
    }
}

- (void)dispose {
    [self.target removeObserver:self forKeyPath:self.keyPath context:nil];
    self.target = nil;
    self.retainedTarget = nil;
}

@end
