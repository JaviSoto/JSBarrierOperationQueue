## JSBarrierOperationQueue
```JSBarrierOperationQueue``` is an ```NSOperationQueue``` subclass that allows you to add operations that behave as a barrier. Basically providing the same functionality ```dispatch_barrier_async``` provides in the ```GCD``` world.

Quote from ```dispatch_barrier_async``` documentation:

>Calls to this function always return immediately after the block has been submitted and never wait for the block to be invoked. When the barrier block reaches the front of a private concurrent queue, it is not executed immediately. Instead, the queue waits until its currently executing blocks finish executing. At that point, the barrier block executes by itself. Any blocks submitted after the barrier block are not executed until the barrier block completes.

## Usage

- Clone the repository using

```bash
$ git clone https://github.com/JaviSoto/JSBarrierOperationQueue.git
```

- Add ```JSBarrierOperationQueue.{h,m}``` to your project.
- Create a ```JSBarrierOperationQueue``` just like you would create an ```NSOperationQueue```.
- Submit operations using ```-addOperation:```
- Submit **barrier operations** using:

```objc
- (void)addBarrierOperation:(NSOperation *)operation;
```

or

```objc
- (void)addBarrierOperationWithBlock:(void (^)(void))block;
```

- This behaves like ```dispatch_barrier_async()``` because it doesn't block the calling thread. If you want the same behaviour as ```dispatch_barrier_sync```, you can just do:

```objc
JSBarrierOperationQueue *queue = ...
NSOperation *operation = ...

[queue addBarrierOperation:operation];
[operation waitUntilFinished];
```

## Tests
- You can run the tests with:

```bash
$ make test
```

## Compatibility
- Supports ARC.
- Compatible with iOS4.0+
- Compatible with Mac OSX 10.6+

## License
Copyright 2012 [Javier Soto](http://twitter.com/javisoto) (ios@javisoto.es)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
 limitations under the License. 

Attribution is not required, but appreciated.