//
//  SubscribeCell.m
//  EventBusDemo
//
//  Created by 张小刚 on 14-2-21.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "SubscribeCell.h"
NSString * const SubscribeCellId = @"SubscribeCellId";
@interface SubscribeCell()
{
    IBOutlet UILabel *_eventNameLabel;
}
@end

@implementation SubscribeCell

- (void)setData: (NSDictionary *)data
{
    _eventNameLabel.text = data[@"eventName"];
}

+ (CGFloat)heightForData:(NSDictionary *)data
{
    return 44.0f;
}

- (void)dealloc {
    [_eventNameLabel release];
    [super dealloc];
}
@end
