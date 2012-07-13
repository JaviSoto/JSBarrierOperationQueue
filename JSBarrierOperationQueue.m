/* 
 Copyright 2012 Javier Soto (ios@javisoto.es)
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. 
 */

#import "JSBarrierOperationQueue.h"

#import <objc/runtime.h>

static char kJSBarrierOperationQueueBarrierOperationKey;
static const NSString *kJSBarrierOperationAssociatedObject = @"JSBarrierOperation";

@interface NSOperation (Barrier)

- (BOOL)isBarrierOperation;

@end

@implementation NSOperation (Barrier)

- (BOOL)isBarrierOperation
{
    return (objc_getAssociatedObject(self, &kJSBarrierOperationQueueBarrierOperationKey) != nil);
}

- (void)setIsBarrierOperation
{
    objc_setAssociatedObject(self, &kJSBarrierOperationQueueBarrierOperationKey, kJSBarrierOperationAssociatedObject, OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface JSBarrierOperationQueue()
{
    dispatch_queue_t _internalSerialQueue;
}
@end

@implementation JSBarrierOperationQueue

- (id)init
{
    if ((self = [super init]))
    {
        _internalSerialQueue = dispatch_queue_create("es.javisoto.barrieroperationqueue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)dealloc
{
    dispatch_release(_internalSerialQueue);
    
    #if !__has_feature(objc_arc)
    [super dealloc];
    #endif
}

#pragma mark - Public

- (void)addBarrierOperation:(NSOperation *)operation
{
    if (dispatch_get_current_queue() != _internalSerialQueue)
    {
        dispatch_sync(_internalSerialQueue, ^{
            [self addBarrierOperation:operation];
        });
    }
    else
    {
        [operation setIsBarrierOperation];
        
        for (NSOperation *op in self.operations)
        {
            // Make this operation wait until the all the operations in the queue finish
            if (!op.isExecuting)
                [operation addDependency:op];
        }
        
        [self addOperation:operation];
    }
}

- (void)addBarrierOperationWithBlock:(void (^)(void))block
{
    [self addBarrierOperation:[NSBlockOperation blockOperationWithBlock:block]];
}

#pragma mark - Private

- (void)makeOperationDependOnAllBarrierOperations:(NSOperation *)operation
{
    for (NSOperation *op in self.operations)
    {
        // Make the operation wait until all the barrier ones finish
        if ([op isBarrierOperation])
            [operation addDependency:op];
    }
}

#pragma mark - Overriding methods

- (void)addOperation:(NSOperation *)op
{
    if (dispatch_get_current_queue() != _internalSerialQueue)
    {
        dispatch_sync(_internalSerialQueue, ^{
            [self addOperation:op];
        });
    }
    else
    {
        [self makeOperationDependOnAllBarrierOperations:op];
        
        [super addOperation:op];
    }
}

- (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait
{
    if (dispatch_get_current_queue() != _internalSerialQueue)
    {
        dispatch_sync(_internalSerialQueue, ^{
            [self addOperations:ops waitUntilFinished:wait];
        });
    }
    else
    {
        for (NSOperation *op in ops)
        {
            [self makeOperationDependOnAllBarrierOperations:op];
        }
        
        [super addOperations:ops waitUntilFinished:wait];
    }
}

- (void)addOperationWithBlock:(void (^)(void))block
{
    if (dispatch_get_current_queue() != _internalSerialQueue)
    {
        dispatch_sync(_internalSerialQueue, ^{
            [self addOperationWithBlock:block];
        });
    }
    else
    {
        NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:block];
        
        [self makeOperationDependOnAllBarrierOperations:blockOp];
        
        [super addOperation:blockOp];
    }
}

@end
