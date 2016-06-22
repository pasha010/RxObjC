//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxEvent.h"

@interface RxEvent ()

@property (nullable, strong, nonatomic) id value;
@property (nullable, strong, nonatomic) NSError *errorValue;

@end

@implementation RxEvent

+ (instancetype)next:(id)value {
    return [[self alloc] initWithType:RxEventTypeNext andTypeValue:value];
}

+ (instancetype)error:(NSError *)error {
    return [[self alloc] initWithType:RxEventTypeError andTypeValue:error];
}

+ (instancetype)completed {
    return [[self alloc] initWithType:RxEventTypeCompleted andTypeValue:nil];
}

- (instancetype)initWithType:(RxEventType)type andTypeValue:(nullable id)value {
    self = [super init];
    if (self) {
        _type = type;
        if (_type == RxEventTypeNext) {
            _value = value;
        } else if (_type == RxEventTypeError) {
            _errorValue = value;
        }
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }

    RxEvent *_other = other;

    if (self.type == _other.type) {
        switch (self.type) {
            case RxEventTypeNext:
                return [self.value isEqual:_other.value];
            case RxEventTypeError:
                return [self.error isEqual:_other.error];
            case RxEventTypeCompleted:
                return YES;
        }
    }

    return NO;
}


@end

@implementation RxEvent (DebugDescription)

- (NSString *)debugDescription {
    switch (self.type) {
        case RxEventTypeNext:
            return [NSString stringWithFormat:@"Next %@", _value];
        case RxEventTypeError:
            return [NSString stringWithFormat:@"Error %@", _errorValue];
        case RxEventTypeCompleted:
            return @"Completed";
    }
    return [super debugDescription];
}

@end

@implementation RxEvent (Properties)

- (BOOL)isStopEvent {
    switch (self.type) {
        case RxEventTypeNext:
            return NO;
        case RxEventTypeError:
            return YES;
        case RxEventTypeCompleted:
            return YES;
    }
    return NO;
}

- (nullable id)element {
    if (self.type == RxEventTypeNext) {
        return self.value;
    }
    return nil;
}

- (nullable NSError *)error {
    if (_type == RxEventTypeError) {
        return self.errorValue;
    }
    return nil;
}

@end