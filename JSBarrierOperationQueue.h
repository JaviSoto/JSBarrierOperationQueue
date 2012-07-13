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

#import <Foundation/Foundation.h>

@interface JSBarrierOperationQueue : NSOperationQueue

/**
 * @discussion Behaves like dispatch_barrier_async. When the operation reaches the front of the queue, it is not executed immediately. Instead, the queue waits until its currently executing operations finish executing. At that point, the barrier operation executes by itself. Any blocks submitted after the barrier operation are not executed until the barrier operation completes.
 * If the operation queue has a max concurrent count of 1, this method behaves like -addOperation:.
 */
- (void)addBarrierOperation:(NSOperation *)operation;

/**
 * @discussion creates an operation which consists on running the provided block and behaves like the -addBarrierOperation: method.
 */
- (void)addBarrierOperationWithBlock:(void (^)(void))block;

@end