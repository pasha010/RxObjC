//
//  RxPerformanceTools
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxPerformanceTools.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import <mach/mach.h>
#import <sys/mman.h>

@interface RxPerformanceTools ()

@property (atomic, assign) int64_t allocations;
@property (atomic, assign) int64_t bytes;
@property (atomic, assign) BOOL registeredMallocHooks;
@property (nonnull, atomic, strong) NSPointerArray *mallocFunctions;
@property (nonnull, atomic, strong) NSPointerArray *proxies;

@end

static void *call0(malloc_zone_t *p, int64_t size) {
    int64_t allocations = 0;
    OSAtomicIncrement64Barrier(&allocations);
    RxPerformanceTools.defaultTools.allocations = allocations;

    int64_t bytes = 0;
    OSAtomicAdd64Barrier(size, &bytes);
    RxPerformanceTools.defaultTools.bytes = bytes;

    void *(*fun)(malloc_zone_t *, int64_t) = [RxPerformanceTools.defaultTools.mallocFunctions pointerAtIndex:0];
    return fun(p, size);
}

static void *call1(malloc_zone_t *p, int64_t size) {
    int64_t allocations = 0;
    OSAtomicIncrement64Barrier(&allocations);
    RxPerformanceTools.defaultTools.allocations = allocations;

    int64_t bytes = 0;
    OSAtomicAdd64Barrier(size, &bytes);
    RxPerformanceTools.defaultTools.bytes = bytes;

    void *(*fun)(malloc_zone_t *, int64_t) = [RxPerformanceTools.defaultTools.mallocFunctions pointerAtIndex:1];
    return fun(p, size);
}

static void *call2(malloc_zone_t *p, int64_t size) {
    int64_t allocations = 0;
    OSAtomicIncrement64Barrier(&allocations);
    RxPerformanceTools.defaultTools.allocations = allocations;

    int64_t bytes = 0;
    OSAtomicAdd64Barrier(size, &bytes);
    RxPerformanceTools.defaultTools.bytes = bytes;

    void *(*fun)(malloc_zone_t *, int64_t) = [RxPerformanceTools.defaultTools.mallocFunctions pointerAtIndex:2];
    return fun(p, size);
}

@implementation RxPerformanceTools

@dynamic memoryInfo;

+ (nonnull RxPerformanceTools *)defaultTools {
    @synchronized ([RxPerformanceTools class]) {
        static dispatch_once_t token;
        static RxPerformanceTools *tools = nil;
        dispatch_once(&token, ^{
            tools = [RxPerformanceTools new];
        });
        return tools;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _registeredMallocHooks = NO;
        _mallocFunctions = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsOpaqueMemory];
        _proxies = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsOpaqueMemory];
        [_proxies addPointer:call0];
        [_proxies addPointer:call1];
        [_proxies addPointer:call2];

    }
    return self;
}

- (RxMemoryInfo)memoryInfo {
    RxMemoryInfo result;
    result.allocations = _allocations;
    result.bytes = _bytes;
    return result;
}


- (void)registerMallocHooks {
    if (_registeredMallocHooks) {
        return;
    }

    _registeredMallocHooks = YES;

    vm_address_t *zones = NULL;
    uint32_t count = 0;
    kern_return_t err = malloc_get_all_zones(mach_task_self(), nil, &zones, &count);

    assert(err == KERN_SUCCESS);

    assert(count <= _proxies.count);

    for (NSUInteger i = 0; i < count; i++) {
        malloc_zone_t *zone = (malloc_zone_t *) zones[i];
        mprotect(zone, sizeof(malloc_zone_t *), PROT_READ | PROT_WRITE);
        char const *name = malloc_get_zone_name(zone);

        assert(name != NULL);

        [_mallocFunctions addPointer:zone->malloc];

        zone->malloc = [_proxies pointerAtIndex:i];

        size_t protectSize = sizeof(malloc_zone_t) * count;

        // https://www.gnu.org/software/hurd/gnumach-doc/Memory-Attributes.html
        kern_return_t protect = vm_protect(mach_task_self(), (vm_address_t) zone, protectSize, 0, PROT_READ | PROT_WRITE);
        assert(protect == KERN_SUCCESS);

        kern_return_t res = vm_protect(mach_task_self(), *zones, protectSize, 0, PROT_READ);
        assert(res == KERN_SUCCESS);
    }
}

@end
