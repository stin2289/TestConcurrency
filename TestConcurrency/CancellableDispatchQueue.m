//
//  CancellableDispatchQueue.m
//  TestConcurrency
//
//  Created by Austin Marusco on 10/23/18.
//  Copyright © 2018 Austin Marusco. All rights reserved.
//


//Question
//How could you cancel a block in the operation queue after  it has been dispatched?
//iOS developers have a "dispatch_after(when, queue, block )" Grand Central Dispatch (GCD) function they can utilize but once it's set up, these calls can not be easily cancelled. Describe how you might implement a more convenient version of this named "cancellable_dispatch_after"

//UUID
//Thread safe
//Future, allow user to pass in which queue the block will be run on, or at least the priority

#import "CancellableDispatchQueue.h"

@interface CancellableDispatchQueue()

@property (nonatomic) NSMutableDictionary *blockLookupDictionary;
@property (nonatomic) dispatch_queue_t lookupDictionaryQueue;

@end

@implementation CancellableDispatchQueue

//Best solution
//This solution is the second one
//https://www.glassdoor.com/Interview/How-could-you-cancel-a-block-in-the-operation-queue-after-it-has-been-dispatched-QTN_751386.htm
//Create typedef of cancelBlock
//After run block is passed in, create __block BOOL variable
//Create cancelBlock, callback in cancelBlock should toggle the __block BOOL variable
//Dispatch_after the block on the specficied queue w/ specified time, BUT check the __block BOOL variable
//Implementation, call cancelBlock(YES), to cancel the block
//This is more of a test of Blocks than it is of DispatchQueues


- (cancellable_block)dispatchAfter:(dispatch_time_t)after queue:(dispatch_queue_t)queue block:(dispatch_block_t)block {
    //Want this variable to be editable in the block scope
    __block BOOL isCancelled = NO;
    
    //Creatae cancel block and add callback to edit isCancellled
    cancellable_block cancelBlock = ^(BOOL cancelled) {
        isCancelled = cancelled;
    };
    
    dispatch_after(after, queue, ^{
        //Check is cancelled value and block to see if nil
        if (isCancelled == NO && block) {
            NSLog(@"austin - block run");
            //Run the block
            block();
        } else {
            NSLog(@"austin - block not run");
        }
    });
    
    //Return a block that can be used to canel
    return cancelBlock;
}







//Better solution
//Create *BOOL *NSNumber and return to user after calling dispatch_after with passed in queue, block, and delay
//If user switches that value to true, then don't run the block


//Naive solution
- (instancetype)init {
	self = [super init];
	if (self) {
        _blockLookupDictionary = [NSMutableDictionary new];
        
        //Create Serial Dispatch Queue for doing work on the lookup Dictionary
        //Ensures thread safety
        dispatch_queue_attr_t queueAttributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,QOS_CLASS_USER_INITIATED,0);
        _lookupDictionaryQueue = dispatch_queue_create("com.apple.cancellableDispatchQueues",queueAttributes);
	}

	return self;
}

-(void)addWithBlock:(dispatch_block_t)block delay:(double)delay completion:(void(^)(NSUUID *uuid))completion  {
	dispatch_async(self.lookupDictionaryQueue, ^{
        //Block holds onto object but stops it from being copied into block
		__block CancellableDispatchQueue *weakSelf = self;
        
        //Created new UUID
		NSUUID *newUUID = [NSUUID UUID];
        //Must use copy on blocks
		weakSelf.blockLookupDictionary[newUUID] = [block copy];

        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
        
        //Any time the blockLookupdictionary is modified, the work must be done on the dedicated serial queue,
        //even the running of the blocks themselves since it leads to removing the block from the dictionary
		dispatch_after(time,self.lookupDictionaryQueue,^{
			void(^genericBlock)(void) = weakSelf.blockLookupDictionary[newUUID];
            //Check to see if block is nil before running
			if (genericBlock) {
                NSLog(@"austin - Ran block with id:%@",newUUID);
                //This is how you run the block
                genericBlock();
            } else {
                NSLog(@"austin - Could not run block with id:%@",newUUID);
            }
			weakSelf.blockLookupDictionary[newUUID] = nil;
        });

        NSLog(@"austin - Enqueued block with id:%@",newUUID);
		completion(newUUID);
	});
}

-(void)cancelWithUUID:(NSUUID *)UUID completion:(void(^)(BOOL success))completion {
    //Removing the blocks from the dictionary requires the work to be done on the serial queue
	dispatch_async(self.lookupDictionaryQueue,^{
        __weak CancellableDispatchQueue *weakSelf = self;
		if (weakSelf.blockLookupDictionary[UUID]) {
			weakSelf.blockLookupDictionary[UUID] = nil;
            NSLog(@"austin - Successfully cancelled block with id:%@",UUID);
			completion(YES);
		} else {
            NSLog(@"austin - Failed to cancel block with id:%@",UUID);
			completion(NO);
		}
    });
}




@end
