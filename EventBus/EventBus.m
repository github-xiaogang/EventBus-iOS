//
//  EventBus.m
//  EventBus
//
//  Created by 张小刚 on 14-2-13.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "EventBus.h"
#import "MAZeroingWeakRef.h"
#import "MAWeakArray.h"

//事件线长度
int const EVENT_COUNT = 10;
//事件生命
int const EVENT_LIFE = 10;

@interface EventBus ()
{
    NSMutableArray * _eventList;
    NSMutableDictionary * _subscriberList;
}

@end

@implementation EventBus

+ (EventBus *)busManager
{
    static EventBus * _sharedInstance = nil;
    if(_sharedInstance == nil){
        _sharedInstance = [[EventBus alloc] init];
    }
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self){
        _subscriberList = [[NSMutableDictionary dictionary] retain];
        _eventList = [[NSMutableArray arrayWithCapacity:EVENT_COUNT] retain];
    }
    return self;
}

- (void)addSubscriber: (id<EventSubscriber>)subscriber event: (NSString *)eventName
{
    NSAssert([subscriber conformsToProtocol:@protocol(EventSubscriber)], @"must conform to EventSubscriber protocol");
    NSAssert([subscriber conformsToProtocol:@protocol(EventAsyncSubscriber)] || [subscriber conformsToProtocol:@protocol(EventSyncSubscriber)], @"EventSubscriber is a abstrct protocol !");
    NSAssert([eventName isKindOfClass:[NSString class]], @"param eventName invalid !");
    NSMutableArray * subscribers = _subscriberList[eventName];
    if([subscribers containsObject:subscriber]){
        NSLog(@"you have already subscribe ----> %@",eventName);
        return;
    }
    if(subscribers == nil){
        subscribers = [MAWeakArray array];      //只有weak ref  subscriber dealloc method can be called as usual.
        [subscribers addObject:subscriber];
        _subscriberList[eventName] = subscribers;
    }else{
        [subscribers addObject:subscriber];
    }
}

- (void)removeSubscriber: (id<EventSubscriber>)subscriber event: (NSString *)eventName
{
    NSAssert([subscriber conformsToProtocol:@protocol(EventSubscriber)], @"must conform to EventSubscriber protocol");
    NSAssert([subscriber conformsToProtocol:@protocol(EventAsyncSubscriber)] || [subscriber conformsToProtocol:@protocol(EventSyncSubscriber)], @"EventSubscriber is a abstrct protocol !");
    NSAssert([eventName isKindOfClass:[NSString class]], @"param eventName invalid !");
    NSMutableArray * subscribers = _subscriberList[eventName];
    //由于使用了MAZeroingRef 因此在subscriber的dealloc调用之前， MAZeroingRef内部已经首先把所有指向subscriber的弱引用全部设置为nil
    //因此这里需要去掉所有为nil的对象
    if([subscribers containsObject:subscriber]) [subscribers removeObject:subscriber];
    [subscribers removeObjectIdenticalTo:nil];
    //对异步订阅者，还要清除包含该订阅者的Event中的相关数据
    if([subscriber conformsToProtocol:@protocol(EventAsyncSubscriber)]){
        AsyncEvent * targetEvent = nil;
        for (AsyncEvent * event in _eventList) {
            if([event.eventName isEqualToString:eventName]){
                targetEvent = event;
                break;
            }
        }
        if(targetEvent && [targetEvent hasMarked:(id<EventAsyncSubscriber>)subscriber]){
            [targetEvent unmarkSubscriber:(id<EventAsyncSubscriber>)subscriber];
        }
    }
}

- (void)publish:(NSString *)eventName eventData: (id)eventData by:(id<EventPublisher>)publisher
{
    NSAssert([publisher conformsToProtocol:@protocol(EventPublisher)], @"must conform to EventPublisher protocol");
    NSAssert([publisher conformsToProtocol:@protocol(EventAsyncPublisher)] || [publisher conformsToProtocol:@protocol(EventSyncPublisher)], @"EventPublisher is a abstrct protocol !");
    NSAssert([eventName isKindOfClass:[NSString class]], @"param eventName invalid !");
    [self _addEvent:eventName eventData:eventData publisher:publisher];
}

- (void)checkEvent: (NSString *)eventName forSubscriber: (id<EventAsyncSubscriber>)subscriber
{
    NSAssert([subscriber conformsToProtocol:@protocol(EventAsyncSubscriber)], @"must conform to EventAsyncSubscriber protocol");
    NSAssert([eventName isKindOfClass:[NSString class]], @"param eventName invalid !");
    [self _checkEvent:eventName forSubscriber:subscriber];
}

- (NSArray *)syncSubscribers: (NSString *)eventName
{
    NSAssert([eventName isKindOfClass:[NSString class]], @"param eventName invalid !");
    NSArray * subscribers = _subscriberList[eventName];
    NSMutableArray * syncSubscribers = [NSMutableArray array];
    for (id<EventSubscriber> aSubscriber in subscribers) {
        if([aSubscriber conformsToProtocol:@protocol(EventSyncSubscriber)]){
            [syncSubscribers addObject:aSubscriber];
        }
    }
    if(syncSubscribers.count == 0) syncSubscribers = nil;
    return syncSubscribers;
}

//force remove
- (void)remove: (NSString *)eventName
{
    NSAssert([eventName isKindOfClass:[NSString class]], @"param eventName invalid !");
    [self _removeEvent:eventName];
}


- (Event *)event: (NSString *)eventName
{
    AsyncEvent * targetEvent = nil;
    for (AsyncEvent * event in _eventList) {
        if([event.eventName isEqualToString:eventName]){
            targetEvent = event;
            break;
        }
    }
    return targetEvent;
}


#pragma mark -----------------   Event life cycle   ----------------

- (void)_addEvent: (NSString *)eventName eventData: (id)eventData publisher: (id<EventPublisher>)publisher
{
    if([publisher conformsToProtocol:@protocol(EventAsyncPublisher)]){
        //遍历该事件是否已经存在，如果存在，则删除之前的事件
        Event * targetEvent = nil;
        for (Event * event in _eventList) {
            if([event.eventName isEqualToString:eventName]){
                targetEvent = event;
                break;
            }
        }
        if(targetEvent) [_eventList removeObject:targetEvent];
        //添加事件到事件列表(先判断现在事件总线是否已满，如果满，则删除最前旧的)
        if(_eventList.count == EVENT_COUNT){
            [_eventList removeObjectAtIndex:0];
        }
        AsyncEvent * event = [[[AsyncEvent alloc] init] autorelease];
        event.eventName = eventName;
        event.life = EVENT_LIFE;
        event.publisher = publisher;
        event.eventData = eventData;
        [_eventList addObject:event];
    }else if([publisher conformsToProtocol:@protocol(EventSyncPublisher)]){
        SyncEvent * event = [[[SyncEvent alloc] init] autorelease];
        event.eventName = eventName;
        event.publisher = (id __weak) publisher;
        event.eventData = eventData;
        event.life = 0;
        NSArray * syncSubsribers = [self syncSubscribers:eventName];
        for (id<EventSyncSubscriber> subscriber in syncSubsribers) {
            //notify sync subscriber
            if([subscriber respondsToSelector:@selector(eventOccurred:event:)]){
                [subscriber eventOccurred:eventName event:event];
            }
        }
    }
}

- (void)_checkEvent: (NSString *)eventName forSubscriber: (id<EventAsyncSubscriber>)subscriber
{
    //先检查subscriber是否订阅了该event
    NSArray * subscribers = _subscriberList[eventName];
    if(![subscribers containsObject:subscriber]){
        NSLog(@"还没有订阅");
        return;
    }
    AsyncEvent * targetEvent = nil;
    for (AsyncEvent * event in _eventList) {
        if([event.eventName isEqualToString:eventName]){
            targetEvent = event;
            break;
        }
    }
    if(targetEvent && targetEvent.life > 0 && ![targetEvent hasMarked:(id<EventAsyncSubscriber>)subscriber]){
        if([subscriber respondsToSelector:@selector(eventOccurred:event:)]){
            [subscriber eventOccurred:targetEvent.eventName event:targetEvent];
        }
        //标记该subscriber
        [targetEvent markSubscriber:subscriber];
        targetEvent.life --;
        if(targetEvent.life == 0){
            [self _removeEvent:eventName];
        }
    }
}

- (void)_removeEvent: (NSString *)eventName
{
    AsyncEvent * targetEvent = nil;
    for (AsyncEvent * event in _eventList) {
        if([event.eventName isEqualToString:eventName]){
            targetEvent = event;
            break;
        }
    }
    if(targetEvent) [_eventList removeObject:targetEvent];
}


- (void)dealloc
{
    [super dealloc];
    [_eventList release];
    [_subscriberList release];
}

@end

/**
 * @class Event
 */


@interface Event ()
{
    MAZeroingWeakRef * _publisherZWR;
}
@end

@implementation Event

- (void)setPublisher:(id<EventPublisher>)publisher
{
    NSAssert([publisher conformsToProtocol:@protocol(EventPublisher)], @"publisher should conforms to  @Protocol(EventPublisher)");
    [_publisherZWR release];
    _publisherZWR = [[MAZeroingWeakRef alloc] initWithTarget:publisher];
}

- (id<EventPublisher>)publisher
{
    return _publisherZWR.target;
}

- (void)dealloc
{
    [_publisherZWR release];
    [_eventData release];
    [_eventName release];
    [super dealloc];
}

@end

/**
 * @class SyncEvent
 */
@implementation SyncEvent

@end

/**
 * @class AsyncEvent
 */
@interface AsyncEvent ()
{
    //已读过的订阅者
    MAWeakArray * _markedSubscribers;
}
@end

@implementation AsyncEvent

- (id)init
{
    self = [super init];
    if(self){
        _markedSubscribers = [[MAWeakArray alloc] init];
    }
    return self;
}

//添加已读订阅者
- (void)markSubscriber: (id<EventAsyncSubscriber>)subscriber
{
    NSAssert([subscriber conformsToProtocol:@protocol(EventAsyncSubscriber)], @"must conform to EventAsyncSubscriber protocol !");
    NSAssert(![_markedSubscribers containsObject:subscriber], @"something error");
    [_markedSubscribers addObject:subscriber];
}

- (void)unmarkSubscriber: (id<EventAsyncSubscriber>)subscriber
{
    NSAssert([subscriber conformsToProtocol:@protocol(EventAsyncSubscriber)], @"must conform to EventAsyncSubscriber protocol !");
    if([_markedSubscribers containsObject:subscriber]) [_markedSubscribers removeObject:subscriber];
    [_markedSubscribers removeObjectIdenticalTo:nil];
}

- (NSArray *)markedSubscribers
{
    if(_markedSubscribers.count == 0) return nil;
    else return _markedSubscribers;
}

- (BOOL)hasMarked: (id<EventAsyncSubscriber>)subscriber
{
    NSAssert([subscriber conformsToProtocol:@protocol(EventAsyncSubscriber)], @"must conform to EventAsyncSubscriber protocol !");
    return ([_markedSubscribers containsObject:subscriber] || [_markedSubscribers containsObject:nil]);
}


- (void)dealloc
{
    [super dealloc];
    [_markedSubscribers release];
}

@end






















