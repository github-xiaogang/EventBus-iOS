//
//  EventView.h
//  EventBusDemo
//
//  Created by 张小刚 on 14-4-25.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;
@protocol EventViewDelegate;
@interface EventView : UIView

@property (nonatomic, assign) int No;
@property (nonatomic, assign) BOOL actionAble;
@property (nonatomic, assign) id<EventViewDelegate> delegate;

- (void)setData: (id)data;
+ (EventView *)newInstance;

@end

@protocol EventViewDelegate <NSObject>

- (void)eventViewSelected: (EventView *)eventView;

@end
