## JSBarrierOperationQueue
```JSBarrierOperationQueue``` is an ```NSOperationQueue``` subclass that allows you to add operations that behave as a barrier. Basically providing the same functionality ```dispatch_barrier_async``` provides in the ```GCD``` world.

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

## Possible issues
- ```NSOperationQueue``` is **thread safe**. Which means you can dispatch operations from different threads without worrying about locking. **I can't assure that behaviour is still present with the current implementation of ```JSBarrierOperationQueue```**.

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