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

## Tests
- You can run the tests with:

```bash
$ make test
```

## Compatibility
- Supports ARC.
- Requires iOS4.0+
- Compatible with Mac OSX 10.6+

## Possible issues
- ```NSOperationQueue``` is *thread safe*. Which means you can dispatch operations from different threads without worrying about locking. *I can't assure that behaviour is still present with the current implementation of ```JSBarrierOperationQueue```*