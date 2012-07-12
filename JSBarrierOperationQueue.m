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
static const NSString *kJSBarrierOperationAssociatedObject = @"kJSBarrierOperation";

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

@implementation JSBarrierOperationQueue

#pragma mark - Public

- (void)addBarrierOperation:(NSOperation *)operation
{
    @synchronized(self)
    {
        [operation setIsBarrierOperation];
        
        for (NSOperation *op in self.operations)
        {
            // Make this operation wait until the currently executing operations finish
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
    @synchronized(self)
    {
        [self makeOperationDependOnAllBarrierOperations:op];
        
        [super addOperation:op];
    }
}

- (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait
{
    @synchronized(self)
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
    @synchronized(self)
    {
        NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:block];
        
        [self makeOperationDependOnAllBarrierOperations:blockOp];
        
        [super addOperation:blockOp];
    }
}

@end
