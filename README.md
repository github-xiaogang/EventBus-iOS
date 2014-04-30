#EventBus-iOS

`why you use it?`

`EventBus`使用起来类似于NSNotification：通过订阅和发布消息实现模块之间的通信， 这种通信机制降低了各个模块之耦合度，非常灵活。
`EventBus`除了提供系统NSNotification的基础功能外，还提供了异步消息，这种消息可以存储在`EventBus`上，可以实现异步读取，延时读取，条件读取。

有两种事件:
1. SyncEvent  类似于使用NotificationCenter发出的通知，不会存储在EventBus上，
              事件发生时会直接调用同步事件订阅者(id< EventSyncSubscriber >)。
2. AsyncEvent 异步事件，具有一定的生命周期(event.life)，会存储在EventBus上(EventBus具有一定的容量)
              异步事件需要异步订阅者(id< EventAsyncSubscriber >)主动去读取事件。

使用: 

订阅者:
  1. 标记自己实现< EventAsyncSubscriber > 或 < EventSyncSubscriber >接口, 表明自己为订阅者;
  2. 在适当时刻使用宏EVENT_SUBSCRIBE(self,eventName)订阅eventName事件，一般可以在init 或 controller的 viewDidLoad方法中;
  3. 事件发生时会回调< EventSubscriber >接口中的方法- (void)eventOccurred: (NSString *)eventName event:(Event *)event，
     对于异步订阅者，需要使用EVENT_CHECK(self,eventName)从EventBus中读取事件，如果有事件，eventOccurred方法会立刻得到调用。
  4. 在适当时刻使用宏EVENT_UNSUBSCRIBE(self,eventName)解订eventName事件，一般可以在dealloc中.
     
发布者：
  1. 标记自己实现< EventAsyncPublisher > 或 < EventSyncPublisher >接口，表明自己为发布者;
  2. 在事件发生时使用宏EVENT_PUBLISH(self,eventName)发布eventName事件，或使用EVENT_PUBLISH_WITHDATA(self,eventName,eventData)
     在发布事件同时传递eventData数据.

to help you use it, I write a Xcode plug-in called [EventBus-iOS-Plugin](https://github.com/github-xiaogang/EventBus-iOS-Plugin)

**EventBus for iOS  non-ARC**

另外:
  代码中使用了 MAZeroingWeakRef 来实现弱引用， 地址: https://github.com/mikeash/MAZeroingWeakRef



详见Demo