//
//  CancellableDispatchQueue.h
//  TestConcurrency
//
//  Created by Austin Marusco on 10/23/18.
//  Copyright © 2018 Austin Marusco. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^cancellable_block)(BOOL cancelled);

@interface CancellableDispatchQueue : NSObject

- (cancellable_block)dispatchAfter:(dispatch_time_t)after queue:(dispatch_queue_t)queue block:(dispatch_block_t)block;

-(void)addWithBlock:(dispatch_block_t)block delay:(double)delay completion:(void(^)(NSUUID *uuid))completion;
-(void)cancelWithUUID:(NSUUID *)UUID completion:(void(^)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
