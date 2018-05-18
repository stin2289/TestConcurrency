//
//  TestLocks.m
//  TestConcurrency
//
//  Created by Austin Marusco on 3/9/18.
//  Copyright © 2018 Austin Marusco. All rights reserved.
//

#import "TestLocks.h"

@interface TestLocks ()

@property (nonatomic) NSLock *lock;

@end

@implementation TestLocks

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // Do any additional setup after loading the view, typically from a nib.
    
    self.lock = [NSLock new];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self method1];
//    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self method2];
//    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self method3];
    });
    
}

- (void)method1 {
    NSLog(@"Running 1st non-critical section of method 1");
    
    [self.lock lock];
    NSLog(@"Method 1 acquired lock");
    [NSThread sleepForTimeInterval:3.0];
    NSLog(@"Running critical section of method 1");
    [self.lock unlock];
    NSLog(@"Method 1 released lock");
    
    NSLog(@"Running 2nd non-critical section of method 1");
}

- (void)method2 {
    NSLog(@"Running 1st non-critical section of method 2");
    [NSThread sleepForTimeInterval:3.0];
    
    [self.lock lock];
    NSLog(@"Method 2 acquired lock");
    [NSThread sleepForTimeInterval:3.0];
    NSLog(@"Running critical section of method 2");
    [self.lock unlock];
    NSLog(@"Method 2 released lock");
    
    NSLog(@"Running 2nd non-critical section of method 2");
}

- (void)method3 {
    NSLog(@"Running 1st non-critical section of method 3");
    [NSThread sleepForTimeInterval:3.0];
    
    [self.lock lock];
    NSLog(@"Method 3 acquired lock");
    NSLog(@"Running critical section of method 3");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self dispatchMethod1];
    });
    [NSThread sleepForTimeInterval:3.0];
    [self.lock unlock];
    NSLog(@"Method 3 released lock");
    
    NSLog(@"Running 2nd non-critical section of method 3");
}

- (void)dispatchMethod1 {
    NSLog(@"Running 1st non-critical section of dispatch method 1");
    
    [self.lock lock];
    NSLog(@"Dispatch Method 1 acquired lock");
    [NSThread sleepForTimeInterval:3.0];
    NSLog(@"Running critical section of dispatch method 1");
    [self.lock unlock];
    NSLog(@"Dispatch Method 1 released lock");
    
    NSLog(@"Running 2nd non-critical section of dispatch method 1");
}

@end
