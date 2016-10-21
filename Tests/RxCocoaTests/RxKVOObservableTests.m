//
//  RxKVOObservableTests.m
//  RxObjC
//
//  Created by Pavel Malkov on 05.08.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RxTest.h"
#import "RxObjCCocoa.h"

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <Cocoa/Cocoa.h>
#endif

@interface RxKVOObservableTests : RxTest
@end

@implementation RxKVOObservableTests
@end

@interface TestClass : NSObject
@property (nullable) NSString *pr;
@end

@implementation TestClass

- (instancetype)init {
    self = [super init];
    if (self) {
        _pr = @"0";
    }
    return self;
}

@end

@interface Parent : NSObject
@property (nullable) RxDisposeBag *disposeBag;
@property (nullable) NSString *val;

- (instancetype)initWithCallback:(void(^)(NSString *__nullable))callback;

@end

@implementation Parent
- (instancetype)initWithCallback:(void (^)(NSString *__nullable))callback {
    self = [super init];
    if (self) {
        _disposeBag = [[RxDisposeBag alloc] init];
        _val = @"";

        NSObject<RxDisposable> *d = [[self rx_observe:@"val" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew retainSelf:NO]
                subscribeNext:callback];
        [d addDisposableTo:_disposeBag];
    }
    return self;
}

- (void)dealloc {
    _disposeBag = nil;
}

@end

@class ParentWithChild;

@interface Child : NSObject
@property (nonnull) RxDisposeBag *disposeBag;

- (instancetype)initWithParent:(ParentWithChild *)parent callback:(void (^)(NSString *__nullable))callback;

@end

@interface ParentWithChild : NSObject
@property (nonnull) NSString *val;
@property (nullable) Child *child;

- (instancetype)initWithCallback:(void(^)(NSString *__nullable))callback;

@end


@implementation Child
- (instancetype)initWithParent:(ParentWithChild *)parent callback:(void (^)(NSString *__nullable))callback {
    self = [super init];
    if (self) {
        _disposeBag = [[RxDisposeBag alloc] init];
        NSObject <RxDisposable> *d = [[parent rx_observe:@"val" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew retainSelf:NO]
                    subscribeNext:callback];
        [d addDisposableTo:_disposeBag];
    }
    return self;
}

@end

@implementation ParentWithChild
- (instancetype)initWithCallback:(void (^)(NSString *__nullable))callback {
    self = [super init];
    if (self) {
        _val = @"";
        _child = [[Child alloc] initWithParent:self callback:callback];
    }
    return self;
}
@end

typedef NS_ENUM(NSInteger, IntEnum) {
    IntEnumOne,
    IntEnumTwo
};

typedef NS_ENUM(NSUInteger, UIntEnum) {
    UIntEnumOne,
    UIntEnumTwo
};

typedef NS_ENUM(int32_t, Int32Enum) {
    Int32EnumOne,
    Int32EnumTwo
};

typedef NS_ENUM(uint32_t, UInt32Enum) {
    UInt32EnumOne,
    UInt32EnumTwo
};

typedef NS_ENUM(int64_t, Int64Enum) {
    Int64EnumOne,
    Int64EnumTwo
};

typedef NS_ENUM(uint64_t, UInt64Enum) {
    UInt64EnumOne,
    UInt64EnumTwo
};

@interface HasStrongProperty : NSObject
@property (nullable, strong) NSObject *property;
@property CGRect frame;
@property CGPoint point;
@property CGSize size;
@property IntEnum intEnum;
@property UIntEnum uintEnum;
@property Int32Enum int32Enum;
@property UInt32Enum uint32Enum;
@property Int64Enum int64Enum;
@property UInt64Enum uint64Enum;
@property NSInteger integer;
@property NSUInteger uinteger;

@end

@implementation HasStrongProperty
- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 100, 100);
        self.point = CGPointMake(3, 5);
        self.size = CGSizeMake(1, 2);
        self.intEnum = IntEnumOne;
        self.uintEnum = UIntEnumOne;
        self.int32Enum = Int32EnumOne;
        self.uint32Enum = UInt32EnumOne;
        self.int64Enum = Int64EnumOne;
        self.uint64Enum = UInt64EnumOne;
        self.integer = 1;
        self.uinteger = 1;
    }

    return self;
}

@end

@interface HasWeakProperty : NSObject
@property (nullable, weak) NSObject *property;
@end

@implementation HasWeakProperty
@end

@implementation RxKVOObservableTests (TestFastObserve)

- (void)test_New {
    TestClass *testClass = [TestClass new];

    RxObservable *os = [testClass rx_observe:@"pr" options:NSKeyValueObservingOptionNew];
    
    __block NSString *latest = nil;

    id <RxDisposable> d = [os subscribeNext:^(NSString *element) {
        latest = element;
    }];

    XCTAssertTrue(latest == nil);

    testClass.pr = @"1";

    XCTAssertEqualObjects(latest, @"1");

    testClass.pr = @"2";

    XCTAssertEqualObjects(latest, @"2");

    testClass.pr = nil;

    XCTAssertTrue(latest == nil);

    testClass.pr = @"3";

    XCTAssertEqualObjects(latest, @"3");

    [d dispose];

    testClass.pr = @"4";

    XCTAssertEqualObjects(latest, @"3");
}

- (void)test_New_And_Initial {
    TestClass *testClass = [TestClass new];

    RxObservable *os = [testClass rx_observe:@"pr" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];

    __block NSString *latest = nil;

    id <RxDisposable> d = [os subscribeNext:^(NSString *element) {
        latest = element;
    }];

    XCTAssertEqualObjects(latest, @"0");

    testClass.pr = @"1";

    XCTAssertEqualObjects(latest, @"1");

    testClass.pr = @"2";

    XCTAssertEqualObjects(latest, @"2");

    testClass.pr = nil;

    XCTAssertTrue(latest == nil);

    testClass.pr = @"3";

    XCTAssertEqualObjects(latest, @"3");

    [d dispose];

    testClass.pr = @"4";

    XCTAssertEqualObjects(latest, @"3");
}

- (void)test_Default {
    TestClass *testClass = [TestClass new];

    RxObservable *os = [testClass rx_observe:@"pr"];

    __block NSString *latest = nil;

    id <RxDisposable> d = [os subscribeNext:^(NSString *element) {
        latest = element;
    }];

    XCTAssertEqualObjects(latest, @"0");

    testClass.pr = @"1";

    XCTAssertEqualObjects(latest, @"1");

    testClass.pr = @"2";

    XCTAssertEqualObjects(latest, @"2");

    testClass.pr = nil;

    XCTAssertTrue(latest == nil);

    testClass.pr = @"3";

    XCTAssertEqualObjects(latest, @"3");

    [d dispose];

    testClass.pr = @"4";

    XCTAssertEqualObjects(latest, @"3");
}

- (void)test_ObserveAndDontRetainWorks {
    __block NSString *latest = nil;
    __block BOOL disposed = NO;

    @autoreleasepool {
        Parent *parent = [[Parent alloc] initWithCallback:^(NSString *string) {
            latest = string;
        }];

        [parent.rx_deallocated subscribeCompleted:^{
            disposed = YES;
        }];

        XCTAssertEqualObjects(latest, @"");
        XCTAssertTrue(disposed == false);

        parent.val = @"1";

        XCTAssertEqualObjects(latest, @"1");
        XCTAssertTrue(disposed == false);

        parent = nil;
    }

    XCTAssertEqualObjects(latest, @"1");
    XCTAssertTrue(disposed == true);
}

- (void)test_ObserveAndDontRetainWorks2 {
    __block NSString *latest = nil;
    __block BOOL disposed = NO;

    @autoreleasepool {
        ParentWithChild *parent = [[ParentWithChild alloc] initWithCallback:^(NSString *string) {
            latest = string;
        }];

        [parent.rx_deallocated subscribeCompleted:^{
            disposed = YES;
        }];

        XCTAssertEqualObjects(latest, @"");
        XCTAssertTrue(disposed == false);

        parent.val = @"1";

        XCTAssertEqualObjects(latest, @"1");
        XCTAssertTrue(disposed == false);

        parent = nil;
    }

    XCTAssertEqualObjects(latest, @"1");
    XCTAssertTrue(disposed == true);
}

@end

#if !DISABLE_SWIZZLING

@implementation RxKVOObservableTests (WeakObserve)

- (void)testObserveWeak_SimpleStrongProperty {
    __block NSString *latest = nil;
    __block BOOL disposed = NO;

    @autoreleasepool {
        HasStrongProperty *root = [HasStrongProperty new];

        [[root rx_observeWeakly:@"property"] subscribeNext:^(NSString *element) {
            latest = element;
        }];

        [root.rx_deallocated subscribeCompleted:^{
            disposed = YES;
        }];

        XCTAssertTrue(latest == nil);
        XCTAssertTrue(!disposed);

        root.property = @"a";

        XCTAssertEqualObjects(latest, @"a");
        XCTAssertTrue(!disposed);

        root = nil;
    }

    XCTAssertTrue(latest == nil);
    XCTAssertTrue(disposed);
}

- (void)testObserveWeak_SimpleWeakProperty {
    __block NSString *latest = nil;
    __block BOOL disposed = NO;

    @autoreleasepool {
        HasWeakProperty *root = [HasWeakProperty new];

        [[root rx_observeWeakly:@"property"] subscribeNext:^(NSString *element) {
            latest = element;
        }];

        [root.rx_deallocated subscribeCompleted:^{
            disposed = YES;
        }];

        XCTAssertTrue(latest == nil);
        XCTAssertTrue(!disposed);

        root.property = @"a";

        XCTAssertEqualObjects(latest, @"a");
        XCTAssertTrue(!disposed);

        root = nil;
    }

    XCTAssertTrue(latest == nil);
    XCTAssertTrue(disposed);
}

- (void)testObserveWeak_ObserveFirst_Weak_Strong_Basic {
    __block NSString *latest = nil;
    __block BOOL disposed = NO;

    @autoreleasepool {
        HasStrongProperty *child = [HasStrongProperty new];

        HasWeakProperty *root = [HasWeakProperty new];

        [[root rx_observeWeakly:@"property.property"] subscribeNext:^(NSString *element) {
            latest = element;
        }];

        [root.rx_deallocated subscribeCompleted:^{
            disposed = YES;
        }];

        XCTAssertTrue(latest == nil);
        XCTAssertTrue(disposed == false);

        root.property = child;

        XCTAssertTrue(latest == nil);
        XCTAssertTrue(disposed == false);

        NSString *one = @"1";

        child.property = one;

        XCTAssertEqualObjects(latest, @"1");
        XCTAssertTrue(disposed == false);

        root = nil;
        child = nil;
    }

    XCTAssertTrue(latest == nil);
    XCTAssertTrue(disposed == true);
}

- (void)testObserveWeak_Weak_Strong_Observe_Basic {
    __block NSString *latest = nil;
    __block BOOL disposed = NO;

    @autoreleasepool {
        HasStrongProperty *child = [HasStrongProperty new];

        HasWeakProperty *root = [HasWeakProperty new];

        root.property = child;

        NSString *one = @"1";

        child.property = one;

        XCTAssertTrue(latest == nil);
        XCTAssertTrue(disposed == false);

        [[root rx_observeWeakly:@"property.property"] subscribeNext:^(NSString *element) {
            latest = element;
        }];

        [root.rx_deallocated subscribeCompleted:^{
            disposed = YES;
        }];


        XCTAssertEqualObjects(latest, @"1");
        XCTAssertTrue(disposed == false);

        root = nil;
        child = nil;
    }

    XCTAssertTrue(latest == nil);
    XCTAssertTrue(disposed == true);
}

- (void)testObserveWeak_ObserveFirst_Strong_Weak_Basic {
    __block NSString *latest = nil;
    __block BOOL disposed = NO;

    @autoreleasepool {
        HasWeakProperty *child = [HasWeakProperty new];

        HasStrongProperty *root = [HasStrongProperty new];

        [[root rx_observeWeakly:@"property.property"] subscribeNext:^(NSString *element) {
            latest = element;
        }];

        [root.rx_deallocated subscribeCompleted:^{
            disposed = YES;
        }];

        XCTAssertTrue(latest == nil);
        XCTAssertTrue(disposed == false);

        root.property = child;

        XCTAssertTrue(latest == nil);
        XCTAssertTrue(disposed == false);

        NSString *one = @"1";

        child.property = one;

        XCTAssertEqualObjects(latest, @"1");
        XCTAssertTrue(disposed == false);

        root = nil;
        child = nil;
    }

    XCTAssertTrue(latest == nil);
    XCTAssertTrue(disposed == true);
}

- (void)testObserveWeak_Strong_Weak_Observe_Basic {
    __block NSString *latest = nil;
    __block BOOL disposed = NO;

    @autoreleasepool {
        HasWeakProperty *child = [HasWeakProperty new];

        HasStrongProperty *root = [HasStrongProperty new];

        root.property = child;

        NSString *one = @"1";

        child.property = one;

        XCTAssertTrue(latest == nil);
        XCTAssertTrue(disposed == false);

        [[root rx_observeWeakly:@"property.property"] subscribeNext:^(NSString *element) {
            latest = element;
        }];

        [root.rx_deallocated subscribeCompleted:^{
            disposed = YES;
        }];


        XCTAssertEqualObjects(latest, @"1");
        XCTAssertTrue(disposed == false);

        root = nil;
        child = nil;
    }

    XCTAssertTrue(latest == nil);
    XCTAssertTrue(disposed == true);
}

// compiler won't release weak references otherwise :(

- (void)testObserveWeak_Strong_Weak_Observe_NilLastPropertyBecauseOfWeak {
    __block BOOL gone = NO;

    RxObservable *dealloc = nil;
    HasWeakProperty *child = [HasWeakProperty new];
    __block NSObject *latest = nil;

    @autoreleasepool {
        HasStrongProperty *root = [HasStrongProperty new];

        root.property = child;

        NSObject *one = nil;

        one = [NSObject new];

        child.property = one;

        XCTAssertTrue(latest == nil);

        RxObservable *observable = [root rx_observeWeakly:@"property.property"];
        [observable subscribeNext:^(id element) {
            latest = element;
        }];

        XCTAssertTrue(latest == one);

        dealloc = one.rx_deallocating;

        one = nil;

        [dealloc subscribeNext:^(id element) {
            gone = YES;
        }];
    }

    XCTAssertTrue(gone);
    XCTAssertTrue(child.property == nil);
    XCTAssertTrue(latest == nil);
}

- (void)testObserveWeak_Weak_Weak_Weak_middle_NilifyCorrectly {
    RxObservable *dealloc = nil;
    __block NSObject *latest = nil;
    HasWeakProperty *root = [HasWeakProperty new];

    __block BOOL gone = NO;

    @autoreleasepool {
        HasWeakProperty *middle = [HasWeakProperty new];
        HasWeakProperty *leaf = [HasWeakProperty new];
        
        root.property = middle;
        middle.property = leaf;
        
        XCTAssert(latest == nil);

        RxObservable *observable = [root rx_observeWeakly:@"property.property.property"];

        [observable subscribeNext:^(id element) {
            latest = element;
        }];
        
        XCTAssertTrue(latest == nil);

        NSObject *one = [NSObject new];
        leaf.property = one;

        XCTAssertTrue(latest == one);

        dealloc = middle.rx_deallocating;
    }

    [dealloc subscribeCompleted:^{
        gone = YES;
    }];

    XCTAssertTrue(gone);
    XCTAssertTrue(root.property == nil);
    XCTAssertTrue(latest == nil);
}

- (void)testObserveWeak_TargetDeallocated {
    HasStrongProperty *root = [HasStrongProperty new];

    __block NSString *latest = nil;
    __block BOOL rootDeallocated = NO;

    @autoreleasepool {
        root.property = @"a";

        XCTAssertTrue(latest == nil);

        [[root rx_observeWeakly:@"property"] subscribeNext:^(id element) {
            latest = element;
        }];

        XCTAssertEqualObjects(latest, @"a");

        [root.rx_deallocated subscribeCompleted:^{
            rootDeallocated = YES;
        }];

        root = nil;
    }

    XCTAssertTrue(latest == nil);
    XCTAssertTrue(rootDeallocated);
}

- (void)testObserveWeakWithOptions_ObserveNotInitialValue {
    HasStrongProperty *root = [HasStrongProperty new];
    __block BOOL rootDeallocated = NO;

    __block NSString *latest=nil;
    @autoreleasepool {
        latest = nil;

        root.property = @"a";

        XCTAssertTrue(latest == nil);

        [[root rx_observeWeakly:@"property" options:NSKeyValueObservingOptionNew] subscribeNext:^(id element) {
            latest = element;
        }];

        XCTAssertTrue(latest == nil);

        root.property = @"b";

        XCTAssertEqualObjects(latest, @"b");

        [root.rx_deallocated subscribeCompleted:^{
            rootDeallocated = YES;
        }];

        root = nil;
    }

    XCTAssertTrue(latest == nil);
    XCTAssertTrue(rootDeallocated);
}

#if !TARGET_OS_IPHONE
// just making sure it's all the same for NS extensions
- (void)testObserve_ObserveNSRect {
    HasStrongProperty *root = [HasStrongProperty new];

    __block NSRect latest = CGRectZero;
    
    XCTAssertTrue(CGRectEqualToRect(latest, CGRectZero));

    id <RxDisposable> disposable = [[root rx_observe:@"frame"] subscribeNext:^(NSValue *e) {
        latest = [e rectValue];
    }];
    
    XCTAssertTrue(CGRectEqualToRect(latest, root.frame));
    
    root.frame = CGRectMake(-2, 0, 0, 1);
    
    XCTAssertTrue(CGRectEqualToRect(latest, CGRectMake(-2, 0, 0, 1)));
    
    __block BOOL rootDeallocated = NO;

    [root.rx_deallocated subscribeCompleted:^{
        rootDeallocated = YES;
    }];
    
    root = nil;

    XCTAssertTrue(CGRectEqualToRect(latest, CGRectMake(-2, 0, 0, 1)));

    XCTAssertTrue(rootDeallocated == NO);

    [disposable dispose];
}

#endif

@end

#endif