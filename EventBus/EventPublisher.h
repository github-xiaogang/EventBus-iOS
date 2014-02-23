//
//  EventPublisher.h
//  EventBus
//
//  Created by 张小刚 on 14-2-13.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventPublisher <NSObject>

@end

/**
 *  异步事件发布者标记接口 (同一管理使用， 只有标记有<EventXX>的接口 才具有EventBus的特性。)
 */
@protocol EventAsyncPublisher <EventPublisher>

@end

/**
 *  同步事件发布者标记接口
 */
@protocol EventSyncPublisher <EventPublisher>

@end
