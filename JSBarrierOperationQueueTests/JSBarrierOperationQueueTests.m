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

#import <SenTestingKit/SenTestingKit.h>

#import "JSBarrierOperationQueue.h"

#define TEST_WAIT_UNTIL_TRUE_SLEEP_SECONDS (0.1)
#define TEST_WAIT_UNTIL_TRUE(expr) \
while( (expr) == NO ) [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:TEST_WAIT_UNTIL_TRUE_SLEEP_SECONDS]];

#define kDefaultOperationDuration 0.1f

@interface _OperationMock : NSOperation
{
    NSTimeInterval _duration;
    dispatch_block_t _startBlock;
    BOOL _isFinished;
}

@end

@implementation _OperationMock

+ (_OperationMock *)operationMockWithDuration:(NSTimeInterval)duration
{
    return [self operationMockWithDuration:duration startBlock:NULL];
}

+ (_OperationMock *)operationMockWithDuration:(NSTimeInterval)duration
                                   startBlock:(dispatch_block_t)startBlock
{
    _OperationMock *op = [[self alloc] init];
    op->_duration = duration;
    op->_startBlock = [startBlock copy];
    
    return op;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isFinished
{
    return _isFinished;
}

- (void)main
{
    if (_startBlock)
        _startBlock();
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _duration * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self finish];
    });
}

- (void)finish
{
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

@end

@interface JSBarrierOperationQueueTests : SenTestCase
{
    JSBarrierOperationQueue *_queue;
}
@end

@implementation JSBarrierOperationQueueTests

- (void)setUp
{
    [super setUp];
    
    _queue = [[JSBarrierOperationQueue alloc] init];
}

- (void)tearDown
{
    STAssertEquals(_queue.operations.count, (NSUInteger)0, @"Shouldn't be any pending operations");
    _queue = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testAddingANormalOperationWorks
{
    __block BOOL done = NO;
    NSTimeInterval duration = 2.0;
    
    _OperationMock *op = [_OperationMock operationMockWithDuration:duration];
    op.completionBlock = ^{
        done = YES;
    };
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, duration * 2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        STAssertTrue(done, @"Should have finished by now");
        
        done = YES;
    });
    
    [_queue addOperation:op];
    
    TEST_WAIT_UNTIL_TRUE(done);
}

- (void)testAddingJustABarrierOperationBehavesAsAddingARegularOperation
{    
    __block BOOL done = NO;
    NSTimeInterval duration = kDefaultOperationDuration;
    
    _OperationMock *op = [_OperationMock operationMockWithDuration:duration];
    op.completionBlock = ^{
        done = YES;
    };
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, duration * 2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        STAssertTrue(done, @"Should have finished by now");
        
        done = YES;
    });
    
    [_queue addBarrierOperation:op];
    
    TEST_WAIT_UNTIL_TRUE(done);
}

- (void)testAddingABarrierOpWaitsForAllOfTheCurrentlyRunningOperationsToFinish
{
    _queue.maxConcurrentOperationCount = 3;
    
    __block BOOL done = NO;
    NSTimeInterval duration = kDefaultOperationDuration;
    
    _OperationMock *op1 = [_OperationMock operationMockWithDuration:duration];
    _OperationMock *op2 = [_OperationMock operationMockWithDuration:duration];
    
    _OperationMock *barrierOp = [_OperationMock operationMockWithDuration:duration startBlock:^{
        STAssertTrue([op1 isFinished], @"Operation 1 should have finished before starting the barrier op");
        STAssertTrue([op2 isFinished], @"Operation 2 should have finished before starting the barrier op");
    }];
    
    [_queue addOperation:op1];
    [_queue addOperation:op2];
    [_queue addBarrierOperation:barrierOp];
    
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, duration * 4 * NSEC_PER_SEC);
    dispatch_after(timeout, dispatch_get_main_queue(), ^(void){
        STAssertTrue(done, @"Should have finished by now");
        
        done = YES;
    });
    barrierOp.completionBlock = ^{
        done = YES;
    };
    TEST_WAIT_UNTIL_TRUE(done);
}

- (void)testAddingABarrierOpPreventsNewOperationsToExecuteUntilThatOneFinishes
{
    _queue.maxConcurrentOperationCount = 2;
    
    __block BOOL done = NO;
    NSTimeInterval duration = kDefaultOperationDuration;

    _OperationMock *barrierOp = [_OperationMock operationMockWithDuration:duration];
    __block _OperationMock *op = nil;
    
    op = [_OperationMock operationMockWithDuration:duration startBlock:^{
        STAssertTrue([barrierOp isFinished], @"The regular operation shouldn't start until the barrier one finishes");
        
        op.completionBlock = ^{
            done = YES;
        };
    }];
    
    [_queue addBarrierOperation:barrierOp];
    [_queue addOperation:op];
    
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, duration * 3 * NSEC_PER_SEC);
    dispatch_after(timeout, dispatch_get_main_queue(), ^(void){
        STAssertTrue(done, @"Should have finished by now");
        
        done = YES;
    });
    TEST_WAIT_UNTIL_TRUE(done);
}

@end
