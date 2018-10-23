//
//  ViewController.m
//  TestConcurrency
//
//  Created by Austin Marusco on 3/9/18.
//  Copyright © 2018 Austin Marusco. All rights reserved.
//

#import "ViewController.h"
#import "TestLocks.h"
#import "TestDispatch.h"
#import "CancellableDispatchQueue.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self testLocks];
    
//    [self testDispatch];
    
//    [self testCancellableDispatchQueuesWithoutCancel];
//    [self testCancellableDispatchQueuesWithCancel];
    
    [self testCancellableDispatchQueueWithoutCancelBestSolution];
    [self testCancellableDispatchQueueWithCancelBestSolution];
}

- (void)testLocks {
    TestLocks *testLocks = [[TestLocks alloc] init];
    NSLog(@"austin - %@",testLocks);
}

- (void)testDispatch {
    TestDispatch *testDispatch = [[TestDispatch alloc] init];
    NSLog(@"austin - %@",testDispatch);
}

- (void)testCancellableDispatchQueuesWithoutCancel {
    //Cancel
    CancellableDispatchQueue *cancelDispatchQueue = [[CancellableDispatchQueue alloc] init];
    __block CancellableDispatchQueue *weakCancelDispatchQueue = cancelDispatchQueue;
    
    void(^block1)(void) = ^{
        NSLog(@"austin - 1 block");
    };
    __block NSUUID *uuid1 = nil;
    [cancelDispatchQueue addWithBlock:block1 delay:5.0 completion:^void (NSUUID *uuid) {
        uuid1 = uuid;
        NSLog(@"austin - ViewController -- new UUID:%@",uuid1);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakCancelDispatchQueue cancelWithUUID:uuid1 completion:^void (BOOL success) {
                NSLog(@"ViewController -- success in cancelling:%d",success);
            }];
        });
    }];
}

- (void)testCancellableDispatchQueuesWithCancel {
    //Cancel
    CancellableDispatchQueue *cancelDispatchQueue = [[CancellableDispatchQueue alloc] init];
    __block CancellableDispatchQueue *weakCancelDispatchQueue = cancelDispatchQueue;
    
    void(^block2)(void) = ^{
        NSLog(@"austin - 2 block");
    };
    __block NSUUID *uuid1 = nil;
    [cancelDispatchQueue addWithBlock:block2 delay:5.0 completion:^void (NSUUID *uuid) {
        uuid1 = uuid;
        NSLog(@"austin - ViewController -- new UUID:%@",uuid1);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakCancelDispatchQueue cancelWithUUID:uuid1 completion:^void (BOOL success) {
                NSLog(@"austin - ViewController -- success in cancelling:%d",success);
            }];
        });
    }];
}

- (void)testCancellableDispatchQueueWithoutCancelBestSolution {
    
    NSLog(@"austin - enqueueing block 1");
    cancellable_block cancelBlock = [[[CancellableDispatchQueue alloc] init] dispatchAfter:dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)) queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) block:^{
        NSLog(@"austin - running block 1");
    }];
    cancelBlock(NO);
}

- (void)testCancellableDispatchQueueWithCancelBestSolution {
    
    NSLog(@"austin - enqueueing block 2");
    cancellable_block cancelBlock = [[[CancellableDispatchQueue alloc] init] dispatchAfter:dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)) queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) block:^{
        NSLog(@"austin - running block 2");
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cancelBlock(YES);
    });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
