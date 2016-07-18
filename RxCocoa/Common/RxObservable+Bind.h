//
//  RxObservable(Bind)
//  RxCocoa
// 
//  Created by Pavel Malkov on 19.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RxObjC/RxObjC.h>

NS_ASSUME_NONNULL_BEGIN

typedef id <RxDisposable> __nonnull(^RxBinder)(id <RxObservableType> __nonnull observable);
typedef RxBinder __nonnull(^RxBinderWithCurriedArg)(id <RxObservableType> __nonnull observable);

@interface NSObject (RxBind) <RxObservableType>
/**
 * Creates new subscription and sends elements to observer.
 * In this form it's equivalent to `subscribe` method, but it communicates intent better, and enables
 * writing more consistent binding code.
 * @param observer: Observer that receives events.
 * @return: Disposable object that can be used to unsubscribe the observer.
 */
- (nonnull id <RxDisposable>)bindTo:(nonnull id <RxObserverType>)observer;

/**
 * Creates new subscription and sends elements to variable.
 * In case error occurs in debug mode, `fatalError` will be raised.
 * In case error occurs in release mode, `error` will be logged.
 * @param variable: Target variable for sequence elements.
 * @return: Disposable object that can be used to unsubscribe the observer.
 */
- (nonnull id <RxDisposable>)bindToVariable:(nonnull RxVariable *)variable;

/**
 * Subscribes to observable sequence using custom binder function.
 * @param binder: Function used to bind elements from `self`.
 * @return: Object representing subscription.
 */
- (nonnull id <RxDisposable>)bindToBinder:(nonnull RxBinder)binder;

/**
 * Subscribes to observable sequence using custom binder function and final parameter passed to binder function
 * after `self` is passed.
 *
 * @param binder: Function used to bind elements from `self`.
 * @param curriedArgument: Final argument passed to `binder` to finish binding process.
 * @return: Object representing subscription.
 */
- (nonnull id)bindToBinder:(nonnull RxBinderWithCurriedArg)binder curriedArgument:(nonnull id)curriedArgument;

/**
 * Subscribes an element handler to an observable sequence.
 * In case error occurs in debug mode, `fatalError` will be raised.
 * In case error occurs in release mode, `error` will be logged.
 * @param onNext: Action to invoke for each element in the observable sequence.
 * @return: Subscription object used to unsubscribe from the observable sequence.
 */
- (nonnull id <RxDisposable>)bindNext:(void(^)(id __nullable next))onNext;

@end

NS_ASSUME_NONNULL_END