//
//  EventSubscriber.h
//  EventBus
//
//  Created by 张小刚 on 14-2-13.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Event;
@protocol EventSubscriber <NSObject>

@required
- (void)eventOccurred: (NSString *)eventName event:(Event *)event;

@end

/**
 *  异步事件订阅者标记接口，异步订阅者标明自己会主动获取读取事件。EventBusManager不会主动发送Event给异步订阅者
 */
@protocol EventAsyncSubscriber <EventSubscriber>

//检查事件，如果存在，EventBus会发送 eventOccurred:

@end

/**
 *  同步事件订阅者标记接口
 */
@protocol EventSyncSubscriber <EventSubscriber>

@end