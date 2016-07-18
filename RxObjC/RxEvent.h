//
// Created by Pavel Malkov on 18.06.16.
// Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RxEventType) {
    RxEventTypeNext = 101,
    RxEventTypeError = 102,
    RxEventTypeCompleted = 103
};

/**
 * Represents a sequence event.
 *
 * Sequence grammar:
 * Next\* (Error | Completed)
*/
@interface RxEvent<__covariant Element> : NSObject

@property (nonatomic, readonly) RxEventType type;
@property (nonatomic, readonly) BOOL isNext;
@property (nonatomic, readonly) BOOL isError;
@property (nonatomic, readonly) BOOL isCompleted;

/// Next element is produced.
+ (nonnull instancetype)next:(nullable Element)value;

/// Sequence terminated with an error.
+ (nonnull instancetype)error:(nullable NSError *)error;

/// Sequence completed successfully.
+ (nonnull instancetype)completed;

@end

@interface RxEvent (DebugDescription)
- (nonnull NSString *)debugDescription;
@end

@interface RxEvent<Element> (Properties)
/// - returns: Is `Completed` or `Error` event.
- (BOOL)isStopEvent;

/// - returns: If `Next` event, returns element value.
- (nullable Element)element;

/// - returns: If `Error` event, returns error.
- (nullable NSError *)error;
@end

typedef void (^RxEventHandler)(RxEvent<id> *__nonnull);

NS_ASSUME_NONNULL_END