//
//  RxPerformanceTools
//  RxObjC
// 
//  Created by Pavel Malkov on 10.07.16.
//  Copyright (c) 2016 Pavel Malkov. All rights reserved.
//

#import "RxPerformanceTools.h"
#import <objc/objc-api.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import <mach/mach.h>

// TODO implement all from PerformanceTools.swift

BOOL registeredMallocHooks = NO;

RxMemoryInfo rx_getMemoryInfo() {
    RxMemoryInfo result;
    result.allocCalls = 0;
    result.bytesAllocated = 0;
    return result;
}

void rx_registerMallocHooks() {
    if (registeredMallocHooks) {
        return;
    }

    registeredMallocHooks = YES;


    vm_address_t *_zones;
    uint32_t count = 0;

    kern_return_t res = malloc_get_all_zones(mach_task_self(), nil, &_zones, &count);

    assert(res == 0);

//    malloc_zone_t *zones;
//    assert(count <= proxies.count);

    for (NSUInteger index = 0; index < count; index++) {
        malloc_zone_t *zoneArray = (malloc_zone_t *)_zones[index];
        char const *name = malloc_get_zone_name(zoneArray);
//        zoneArray->malloc = proxies[index];

        vm_size_t protectSize = ((vm_size_t) sizeof(malloc_zone_t)) * ((vm_size_t) count);

//        vm_protect(mach_task_self(), zoneArray->malloc, protectSize, 0, VM_PROT_READ | VM_PROT_WRITE);

        /*
         * let protectSize = vm_size_t(sizeof(malloc_zone_t)) * vm_size_t(count)

        if true {
            let addressPointer = UnsafeMutablePointer<vm_address_t>(zoneArray)
            let res = vm_protect(mach_task_self_, addressPointer.memory, protectSize, 0, PROT_READ | PROT_WRITE)
            assert(res == 0)
        }

        zoneArray.memory.memory = zone

        if true {
            let res = vm_protect(mach_task_self_, _zones.memory, protectSize, 0, PROT_READ)
            assert(res == 0)
        }
         */
    }
}