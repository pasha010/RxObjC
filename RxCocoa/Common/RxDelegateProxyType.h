//
//  RxDelegateProxyType
//  RxObjC
// 
//  Created by Pavel Malkov on 05.09.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RxObjCCocoa.h"
#import <RxObjC/RxObjC.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * `DelegateProxyType` protocol enables using both normal delegates and Rx observable sequences with
 * views that can have only one delegate/datasource registered.
 *
 * `Proxies` store information about observers, subscriptions and delegates
 * for specific views.
 *
 * Type implementing `DelegateProxyType` should never be initialized directly.
 *
 * To fetch initialized instance of type implementing `DelegateProxyType`, `proxyForObject` method
 * should be used.
 *
 * This is more or less how it works.



      +-------------------------------------------+
      |                                           |
      | UIView subclass (UIScrollView)            |
      |                                           |
      +-----------+-------------------------------+
                  |
                  | Delegate
                  |
                  |
      +-----------v-------------------------------+
      |                                           |
      | Delegate proxy : DelegateProxyType        +-----+---->  Observable<T1>
      |                , UIScrollViewDelegate     |     |
      +-----------+-------------------------------+     +---->  Observable<T2>
                  |                                     |
                  |                                     +---->  Observable<T3>
                  |                                     |
                  | forwards events                     |
                  | to custom delegate                  |
                  |                                     v
      +-----------v-------------------------------+
      |                                           |
      | Custom delegate (UIScrollViewDelegate)    |
      |                                           |
      +-------------------------------------------+


 * Since RxCocoa needs to automagically create those Proxys
 * ..and because views that have delegates can be hierarchical
 *
 * UITableView : UIScrollView : UIView
 *
 * .. and corresponding delegates are also hierarchical
 *
 * UITableViewDelegate : UIScrollViewDelegate : NSObject
 *
 * .. and sometimes there can be only one proxy/delegate registered,
 * every view has a corresponding delegate virtual factory method.
 *
 * In case of UITableView / UIScrollView, there is

    extension UIScrollView {
        public func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
            return RxScrollViewDelegateProxy(parentObject: self)
        }
    ....


 * and override in UITableView

    extension UITableView {
        public override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        ....
*/

@protocol RxDelegateProxyType <NSObject>
/**
 * Creates new proxy for target object.
 */
+ (nonnull id)createProxyForObject:(nonnull id)object;

/**
 * Returns assigned proxy for object.
 * @param object: Object that can have assigned delegate proxy.
 * @return: Assigned delegate proxy or `nil` if no delegate proxy is assigned.
 */
+ (nullable id)assignedProxyFor:(nonnull id)object;

/**
 * Assigns proxy to object.
 * @param object: Object that can have assigned delegate proxy.
 * @param proxy: Delegate proxy object to assign to `object`.
 */
+ (void)assignProxy:(nonnull id)proxy toObject:(nonnull id)object;

/**
 * Returns designated delegate property for object.
 * Objects can have multiple delegate properties.
 * Each delegate property needs to have it's own type implementing `DelegateProxyType`.
 * @param object: Object that has delegate property.
 * @return: Value of delegate property.
 */
+ (nullable id)currentDelegateFor:(nonnull id)object;

/**
 * Sets designated delegate property for object.
 * Objects can have multiple delegate properties.
 * Each delegate property needs to have it's own type implementing `DelegateProxyType`.
 * @param toObject: Object that has delegate property.
 * @param delegate: Delegate value.
 */
+ (void)setCurrentDelegate:(nullable id)delegate toObject:(nonnull id)object;

/**
 * Returns reference of normal delegate that receives all forwarded messages
 * through `self`.
 * @return: Value of reference if set or nil.
 */
- (nullable id)forwardToDelegate;

/**
 * Sets reference of normal delegate that receives all forwarded messages
 * through `self`.
 * @param forwardToDelegate: Reference of delegate that receives all messages through `self`.
 * @param retainDelegate: Should `self` retain `forwardToDelegate`.
 */
- (void)setForwardToDelegate:(nullable id)forwardToDelegate retainDelegate:(BOOL)retainDelegate;
@end

@interface NSObject (RxDelegateProxyType) <RxDelegateProxyType>

/**
 * Returns existing proxy for object or installs new instance of delegate proxy.
 * @param object: Target object on which to install delegate proxy.
 * @return: Installed instance of delegate proxy.
     extension UISearchBar {

         public var rx_delegate: DelegateProxy {
            return RxSearchBarDelegateProxy.proxyForObject(self)
         }

         public var rx_text: ControlProperty<String> {
             let source: Observable<String> = self.rx_delegate.observe(#selector(UISearchBarDelegate.searchBar(_:textDidChange:)))
             ...
         }
     }
 */
+ (nonnull id)proxyForObject:(nonnull id)object;

/**
 * Sets forward delegate for `DelegateProxyType` associated with a specific object and return disposable that can be used to unset the forward to delegate.
 * Using this method will also make sure that potential original object cached selectors are cleared and will report any accidental forward delegate mutations.
 * @param forwardDelegate: Delegate object to set.
 * @param retainDelegate: Retain `forwardDelegate` while it's being set.
 * @param object: Object that has `delegate` property.
 * @return: Disposable object that can be used to clear forward delegate.
 */
+ (nonnull id <RxDisposable>)installForwardDelegate:(nonnull id)forwardDelegate
                                     retainDelegate:(BOOL)retainDelegate
                                   onProxyForObject:(nonnull id)object;

@end

@interface NSObject (RxSubscribeProxyDataSourceForObject) <RxObservableType>

- (nonnull id <RxDisposable>)subscribeProxyDataSourceForObject:(nonnull id)object
                                                    dataSource:(nonnull id)dataSource
                                              retainDataSource:(BOOL)retainDataSource
                                                       binding:(void (^)(id <RxDelegateProxyType>, RxEvent *))binding;

@end

NS_ASSUME_NONNULL_END